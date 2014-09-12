# Remember everything in this file will be loaded by Rake, don't make it too heavy...

$LOAD_PATH << File.expand_path('../../lib', __FILE__)

# Default environment
# Try to avoid using RACK_ENV as a switch unless absolutely necessary.
# Use environment variables instead.
ENV['RACK_ENV'] ||= 'development'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
if File.exists?(ENV['BUNDLE_GEMFILE'])
  require 'bundler/setup'
  Bundler.require
end

if ENV['RACK_ENV'] == 'production'
  require 'rumour_mill/environment_variables'
  RumourMill::EnvironmentVariables.check
  # Initialise NewRelic
  require 'newrelic_rpm'
end

# Load Rumour Mill
require 'rumour_mill'