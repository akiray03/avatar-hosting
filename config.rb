require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require 'sinatra/base'
require 'sinatra/reloader'
require 'rack-flash'
require 'slim'
require 'RMagick'

require 'uri'
require 'cgi'
require 'digest/md5'
require 'fileutils'

module AvatarConfig
  DATA_DIR      = File.expand_path("../data", __FILE__)
  AVATAR_PREFIX = "/avatar"
  EMAIL_DOMAIN  = "avatar.example.com"
  FILE_TYPE     = %w(jpg jpeg png gif)
  GRAVATOR_REDIRECT = "http://gravatar.com"
end

%w(avatar app).each do |file|
  require File.expand_path("../#{file}", __FILE__)
end
