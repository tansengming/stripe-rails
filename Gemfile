source 'https://rubygems.org'

# Specify your gem's dependencies in stripe-rails.gemspec
gemspec

gem 'rake'

group :development, :test do
  gem 'm'
end

group :test do
  gem 'mocha'
  gem 'simplecov', require: false
  gem 'stripe-ruby-mock'
  gem 'webmock'
  # System tests
  gem 'capybara'
  gem 'puma'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end