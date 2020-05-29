require File.expand_path('lib/stripe/rails/version', __dir__)

Gem::Specification.new do |gem|
  gem.authors       = ["Charles Lowell", "Nola Stowe", "SengMing Tan"]
  gem.email         = ["sengming@sanemen.com"]
  gem.description   = "A gem to integrate stripe into your rails app"
  gem.summary       = "A gem to integrate stripe into your rails app"
  gem.homepage      = "https://github.com/tansengming/stripe-rails"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "stripe-rails"
  gem.require_paths = ["lib"]
  gem.version       = Stripe::Rails::VERSION
  gem.add_dependency 'rails', '>= 5.1'
  gem.add_dependency 'stripe', '>= 3.15.0'
  gem.add_dependency 'responders'
end
