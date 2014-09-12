# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

$LOAD_PATH << File.expand_path('lib', File.dirname(__FILE__))
require File.join(File.dirname(__FILE__), 'config/boot')

FileList['./lib/tasks/**/*.rake'].each { |task| load task }

task :default => :spec
