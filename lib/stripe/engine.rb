require 'stripe'

module Stripe
  class Engine < ::Rails::Engine
    isolate_namespace Stripe

    class << self
      attr_accessor :testing
    end

    config.stripe = Struct.new(:api_base, :api_key, :verify_ssl_certs, :publishable_key, :endpoint, :debug_js).new

    initializer 'stripe.configure.defaults', :before => 'stripe.configure' do |app|
      stripe = app.config.stripe
      stripe.api_key ||= ENV['STRIPE_API_KEY']
      stripe.endpoint ||= '/stripe'
      if stripe.debug_js.nil?
        stripe.debug_js = ::Rails.env.development?
      end
    end

    initializer 'stripe.configure' do |app|
      [:api_base, :api_key, :verify_ssl_certs].each do |key|
        value = app.config.stripe.send(key)
        Stripe.send("#{key}=", value) unless value.nil?
      end
      $stderr.puts <<-MSG unless Stripe.api_key
No stripe.com API key was configured for environment #{::Rails.env}! this application will be
unable to interact with stripe.com. You can set your API key with either the environment
variable `STRIPE_API_KEY` (recommended) or by setting `config.stripe.api_key` in your
environment file directly.
      MSG
    end

    initializer 'stripe.javascript_helper' do
      ActiveSupport.on_load :action_controller do
        helper Stripe::JavascriptHelper
      end
    end

    initializer 'stripe.plans_and_coupons' do |app|
      for configuration in %w(plans coupons)
        path = app.root.join("config/stripe/#{configuration}.rb")
        load path if path.exist?
      end
    end

    rake_tasks do
      load 'stripe/rails/tasks.rake'
    end
  end
end