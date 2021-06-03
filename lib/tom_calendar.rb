require 'aws-sdk-dynamodb'
require 'googleauth/client_id'
require 'googleauth/web_user_authorizer'
require 'googleauth/token_store'
require "google/apis/calendar_v3"
require 'json'
require 'digest'
require_relative './tom_memcache.rb'

module StatusCodeStr
  OK           = "Content-type: text/plain\nStatus: 200 OK\n\n".freeze
  BAD_REQUEST  = "Content-type: text/plain\nStatus: 400 Bad Request\n\n".freeze
  UNAUTHORIZED = "Content-type: text/plain\nStatus: 401 Unauthorized\n\n".freeze

  def self.bad_request_error_message(message)
    "Content-type: text/plain\nStatus: 400 Bad Request #{message}\n\n".freeze
  end

  def self.error_message(message)
    "Content-type: text/plain\nStatus: 500 Internal Server Error\n\n#{message}".freeze
  end

  def self.plain_text(message)
    "Content-type: text/plain\n\n#{message}".freeze
  end
end

GOOGLE_PERMISSION_SCOPES = ['profile', 'email', 'https://www.googleapis.com/auth/calendar'].freeze
APPLICATION_NAME = 'TomCalendar'.freeze

class DynamoDBTokenStore < Google::Auth::TokenStore
  def initialize(dynamodb_connection)
    @dynamodb = dynamodb_connection
  end

  def store(id, token)
    item = JSON.parse(token)
    item[:id] = id
    
    params = {
      table_name: 'GoogleTokens',
      item: item
    }

    begin
      @dynamodb.put_item(params)
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      raise "Unable to add token: #{item.to_s}"
    end
  end

  def load(id)
    params = {
      table_name: 'GoogleTokens',
      key: { id: id }
    }

    begin
      item = @dynamodb.get_item(params).item
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      raise "Unable to get token for id: #{id}"
    end

    item['expiration_time_millis'] = item['expiration_time_millis'].to_i

    return item.to_json
  end

  def delete(id)
    params = {
      table_name: 'GoogleTokens',
      key: { id: id }
    }

    begin
      @dynamodb.delete_item(params)
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      raise "Unable to delete token for id: #{id}"
    end
  end
end

def get_google_authorizer(dynamodb_connection)
  client_id   = Google::Auth::ClientId.new(ENV['GOOGLE_OAUTH_CLIENT_ID'], ENV['GOOGLE_OAUTH_CLIENT_SECRET'])
  token_store = DynamoDBTokenStore.new(dynamodb_connection)
  authorizer  = Google::Auth::UserAuthorizer.new(client_id, GOOGLE_PERMISSION_SCOPES, token_store, 'https://tomcalendar.com')
  authorizer
end

def get_session_id_from_cookies()
  session_id = ENV['HTTP_COOKIE']&.split(';')&.find{ |cookie| cookie.match?('session_id') }&.sub('session_id=','')&.strip
  return nil unless session_id
  return nil if session_id == ''
  return JSON.parse(session_id)
end

def refresh_tokens_and_cookie_session_id_is_valid?(cookie_session_id, time_zone=nil)
  return false unless cookie_session_id
  session_id = JSON.parse(cookie_session_id)

  cache_result = TomMemcache::get("refresh_tokens_and_cookie_session_id_is_valid?#{cookie_session_id}#{time_zone}").freeze
  return (cache_result.downcase == "true") if cache_result

  begin
    dynamodb = Aws::DynamoDB::Client.new(region: ENV['AWS_REGION'])

    params = {
      table_name: 'Sessions',
      key: session_id
    }

    item = dynamodb.get_item(params).item

    return false unless item
    google_authorizer = get_google_authorizer(dynamodb)
    google_credentials = google_authorizer.get_credentials(item['google_id'])
    google_credentials.refresh!
    return false if google_credentials.expired?

    # update the item
    item['last_updated'] = Time.now.to_s
    item['time_zone']    = time_zone

    session_params = {
      table_name: 'Sessions',
      item: item
    }

    dynamodb.put_item(session_params)

    TomMemcache::set("refresh_tokens_and_cookie_session_id_is_valid?#{cookie_session_id}#{time_zone}", 'true', 60).freeze
    return true
  rescue Exception => e
    return false
  end
end

def get_primary_google_calendar(google_id)
  dynamodb              = Aws::DynamoDB::Client.new(region: ENV['AWS_REGION'])
  google_authorizer     = get_google_authorizer(dynamodb)
  service               = Google::Apis::CalendarV3::CalendarService.new
  service.authorization = google_authorizer.get_credentials(google_id)
  service.client_options.application_name = 'TomCalendar'.freeze

  page_token = nil
  begin
    calendar_list = service.list_calendar_lists(page_token: page_token)
    calendar_list.items.each do |item|
      return item if item.primary?
    end
    if calendar_list.next_page_token != page_token
      page_token = calendar_list.next_page_token
    else
      page_token = nil
    end
  end while !page_token.nil?
  return nil
end

def calculate_time_passed_in_words(previous_time)
  seconds = Time.now - previous_time
  return '1 second ago' if seconds < 2
  return "#{seconds.to_i} seconds ago" if seconds < 60

  minutes = seconds / 60
  return '1 minute ago' if minutes < 2
  return "#{minutes.to_i} minutes ago" if minutes < 60

  hours = minutes / 60
  return '1 hour ago' if hours < 2
  return "#{hours.to_i} hours ago" if hours < 24

  days = hours / 24
  return '1 day ago' if days < 2
  return "#{days.to_i} days ago" if days < 365

  years = days / 365
  return '1 year ago' if years < 2
  return "#{years.to_i} years ago"
end

def exec_ruby_vm_code(file_path)
  if File.exist?(file_path)
    return RubyVM::InstructionSequence.load_from_binary( File.open(file_path, 'r').readlines.join('') ).eval
  else
    return StatusCodeStr::BAD_REQUEST
  end
end

$app_server_env = {}
class TomEnv
  def self.init_thread()
    $app_server_env[Thread.current.object_id] = {}
  end
  def self.get(key)
    return $app_server_env.fetch(Thread.current.object_id)&.fetch(key)
  end
  def self.set(key, value)
    return $app_server_env[Thread.current.object_id][key] = value
  end
end
