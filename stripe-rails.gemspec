# -*- encoding: utf-8 -*-
require File.expand_path('../lib/stripe-rails/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["rubygeek"]
  gem.email         = ["nola@rubygeek.com"]
  gem.description   = "A gem to integrate stripe into your rails app"
  gem.summary       = "A gem to integrate stripe into your rails app"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "stripe-rails"
  gem.require_paths = ["lib"]
  gem.version       = Stripe::Rails::VERSION
  gem.add_dependency 'railties', '~> 3.0'
  gem.add_dependency 'stripe'

  gem.add_development_dependency 'tzinfo'
  gem.add_development_dependency 'mocha'
end
