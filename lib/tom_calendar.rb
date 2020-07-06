require 'aws-sdk-dynamodb'
require 'googleauth'
require 'googleauth/web_user_authorizer'
require 'googleauth/token_store'

GOOGLE_PERMISSION_SCOPES = ['profile', 'email', 'https://www.googleapis.com/auth/calendar'].freeze

class DynamoDBTokenStore < Google::Auth::TokenStore
  def initialize(dynamodb_connection)
    @dynamodb = dynamodb_connection
  end

  def self.default()
  end

  def store(id, token)
  end

  def load(id)
  end

  def delete(id)
  end
end

def get_google_authorizer(dynamodb_connection)
  client_id   = Google::Auth::ClientId.new(ENV['GOOGLE_OAUTH_CLIENT_ID'], ENV['GOOGLE_OAUTH_CLIENT_SECRET'])
  token_store = DynamoDBTokenStore.new(dynamodb_connection)
  authorizer  = Google::Auth::UserAuthorizer.new(client_id, GOOGLE_PERMISSION_SCOPES, token_store)
  authorizer
end



