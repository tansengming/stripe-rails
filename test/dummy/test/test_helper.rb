# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
ENV['STRIPE_SECRET_KEY'] = 'XYZ'

require File.expand_path("../../config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

Stripe::Engine.testing = true
require 'mocha/setup'

require 'irb'
