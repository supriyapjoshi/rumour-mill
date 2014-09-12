require File.dirname(__FILE__) + '/config/boot'
require 'rumour_mill/api'

run Rack::URLMap.new(
  '/' => RumourMill::API
)
