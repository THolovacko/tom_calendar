require 'aws-sdk-dynamodb'
require 'googleauth'
require 'googleauth/web_user_authorizer'
require 'googleauth/token_store'

class TomCalendarTokenStore < Google::Auth::TokenStore
  def initialize(aws_dynamo_client)
    @dynamodb = aws_dynamo_client
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



