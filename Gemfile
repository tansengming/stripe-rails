source 'https://rubygems.org'

# Specify your gem's dependencies in stripe-rails.gemspec
gemspec

gem "rake"

group :development, :test do
  gem 'm'
end

group :test do
  gem 'mocha'
  gem 'simplecov', require: false
  gem 'webmock'
  gem 'stripe-ruby-mock'
  gem 'puma'                # required for system tests
  gem 'capybara'            # ditto
  gem "selenium-webdriver"  # ditto
  gem 'chromedriver-helper' # ditto
end