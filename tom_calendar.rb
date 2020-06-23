#! /usr/bin/env ruby

require 'sinatra'

set :bind, '0.0.0.0'
set :port, 8000

get '/' do
  'Tom Calendar testttt'
end
