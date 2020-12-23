require 'aws-sdk-dynamodb'
require 'googleauth/client_id'
require 'googleauth/web_user_authorizer'
require 'googleauth/token_store'
require 'json'
require 'digest'


=begin
@optimize: requiring library is taking pretty long:
  real    0m0.576s
  user    0m0.486s
  sys     0m0.089s

  requiring dynamodb is about .4 seconds
=end

module StatusCodeStr
  OK           = "Content-type: text/plain\nStatus: 200 OK\n\n".freeze
  BAD_REQUEST  = "Content-type: text/plain\nStatus: 400 Bad Request\n\n".freeze
  UNAUTHORIZED = "Content-type: text/plain\nStatus: 401 Unauthorized\n\n".freeze

  def self.error_message(message)
    "Content-type: text/plain\nStatus: 500 Internal Server Error\n\n#{message}".freeze
  end

  def self.plain_text(message)
    "Content-type: text/plain\n\n#{message}".freeze
  end
end

GOOGLE_PERMISSION_SCOPES = ['profile', 'email', 'https://www.googleapis.com/auth/calendar'].freeze
APPLICATION_NAME = "TomCalendar".freeze

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

def refresh_tokens_and_cookie_session_id_is_valid?(cookie_session_id)
  return false unless cookie_session_id
  session_id = JSON.parse(cookie_session_id)

  begin
    dynamodb = Aws::DynamoDB::Client.new(region: ENV['AWS_REGION'])

    params = {
      table_name: 'Sessions',
      key: session_id
    }

    item = dynamodb.get_item(params).item

    # @test: safari mobile has max 24 hours cookie lifetime (might need to rethink session id and passwords etc.)
    return false unless item
    google_authorizer = get_google_authorizer(dynamodb)
    google_credentials = google_authorizer.get_credentials(item['google_id'])
    google_credentials.refresh!
    return false if google_credentials.expired?

    # update the item
    item['last_updated'] = Time.now.to_s

    session_params = {
      table_name: 'Sessions',
      item: item
    }

    dynamodb.put_item(session_params)

    return true
  rescue Exception => e
    return false
  end
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
