source 'https://rubygems.org'

# Specify your gem's dependencies in stripe-rails.gemspec
gemspec

gem 'rake'

group :development, :test do
  gem 'm'
end

group :test do
  gem 'mocha'
  gem 'simplecov', '< 0.18', require: false
  gem 'stripe-ruby-mock'
  gem 'webmock'
  # System tests
  gem 'capybara', '>= 3.38.0' # https://github.com/teamcapybara/capybara/issues/2598
  gem 'puma'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
