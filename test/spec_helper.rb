require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end

require 'minitest/autorun'

require 'webmock/minitest'
WebMock.disable_net_connect! allow_localhost: true, allow: ['codeclimate.com', 'chromedriver.storage.googleapis.com']

# Chrome Setup
require 'selenium-webdriver'
require 'capybara'
require 'webdrivers'
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
ENV['STRIPE_SECRET_KEY'] = 'XYZ'

require File.expand_path("dummy/config/environment.rb", __dir__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{__dir__}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
end

Stripe::Engine.testing = true
require 'mocha/setup'

require 'irb'
