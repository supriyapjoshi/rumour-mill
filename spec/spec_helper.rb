require 'rspec'
require 'rspec/fire'
require 'simplecov' # At the top because simplecov needs to watch files being loaded
require 'rack/test'

# RACK_ENV must be set before boot.
ENV['RACK_ENV'] = 'test'
require_relative '../config/boot'

RSpec.configure do |config|
  config.include(RSpec::Fire)
end

