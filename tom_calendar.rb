#! /usr/bin/env ruby

require 'sinatra'
require 'json'


set :bind, '0.0.0.0'
set :port, 8000

enable :sessions


get '/foo' do
  request.env.to_json
end

get '/google' do
  logger.info 'about to redirect to google'
  redirect to('https://google.com')
end

get '/' do
  session[:testing] = 'session test'
  erb :index, :locals => {test_var: session[:testing]}
end
