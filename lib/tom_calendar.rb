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
  authorizer  = Google::Auth::UserAuthorizer.new(client_id, GOOGLE_PERMISSION_SCOPES, token_store, 'postmessage')
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

    # @remember: should occasionally reset password hash?

    return false unless item
    google_authorizer = get_google_authorizer(dynamodb)
    google_credentials = google_authorizer.get_credentials(item['google_id'])
    google_credentials.refresh!
    return false if google_credentials.expired?

    return true
  rescue Exception => e
    #error = "#{e.message}:#{e.backtrace.inspect}"
    return false
  end
end



