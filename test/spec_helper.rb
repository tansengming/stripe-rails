require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

require 'minitest/autorun'

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
ENV['STRIPE_SECRET_KEY'] = 'XYZ'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

Stripe::Engine.testing = true
require 'mocha/setup'

require 'irb'