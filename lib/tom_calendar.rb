require 'aws-sdk-dynamodb'
require 'googleauth'
require 'googleauth/web_user_authorizer'
require 'googleauth/token_store'
require 'jwt'
require 'json'
require 'digest'

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

def decode_google_id_token(id_token)
  user_data = JWT.decode(id_token, nil, false).first
  raise 'invalid iss' unless user_data['iss'] == 'https://accounts.google.com'.freeze
  raise 'invalid aud' unless user_data['aud'] == ENV['GOOGLE_OAUTH_CLIENT_ID']
  raise 'invalid exp' unless user_data['exp'] > 0
  user_data
end



