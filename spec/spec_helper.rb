require 'rspec'
require 'simplecov' # At the top because simplecov needs to watch files being loaded
require 'rack/test'

# RACK_ENV must be set before boot.
ENV['RACK_ENV'] = 'test'
require_relative '../config/boot'
