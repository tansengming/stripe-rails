source 'https://rubygems.org'

# Specify your gem's dependencies in stripe-rails.gemspec
gemspec

gem "bundler", ">= 1.3.0"
gem "rake"
gem 'tzinfo'
gem 'mocha'
gem 'pry'

group :development, :test do
  gem 'm'
end

group :test do
  gem 'simplecov', require: false
  # NOTE: tracking master temporarily until they
  # release https://github.com/rebelidealist/stripe-ruby-mock/pull/433
  gem 'stripe-ruby-mock', github: 'rebelidealist/stripe-ruby-mock'
  gem 'poltergeist' # required for system tests
  gem 'phantomjs'   # ditto
  gem 'puma'        # ditto
  gem 'webmock'
end