# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
ENV['STRIPE_SECRET_KEY'] = 'XYZ'

require File.expand_path("../../config/environment.rb",  __FILE__)
require "rails/test_help"
