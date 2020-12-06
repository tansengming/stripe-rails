require 'stripe'

module Stripe
  class Engine < ::Rails::Engine
    isolate_namespace Stripe

    class << self
      attr_accessor :testing
    end

    stripe_config = config.stripe = Struct.new(:api_base, :api_version, :secret_key, :ignore_missing_secret_key, :verify_ssl_certs, :signing_secret, :signing_secrets, :publishable_key, :endpoint, :debug_js, :auto_mount, :eager_load, :open_timeout, :read_timeout) do
      # for backwards compatibility treat signing_secret as an alias for signing_secrets
      def signing_secret=(value)
        self.signing_secrets = value.nil? ? value : Array(value)
      end

      def signing_secret
        self.signing_secrets && self.signing_secrets.first
      end
    end.new

    def stripe_config.api_key=(key)
      warn "[DEPRECATION] to align with stripe nomenclature, stripe.api_key has been renamed to config.stripe.secret_key"
      self.secret_key = key
    end

    initializer 'stripe.configure.defaults', :before => 'stripe.configure' do |app|
      stripe = app.config.stripe
      stripe.secret_key ||= ENV['STRIPE_SECRET_KEY']
      stripe.publishable_key ||= ENV['STRIPE_PUBLISHABLE_KEY']
      stripe.endpoint ||= '/stripe'
      stripe.auto_mount = true if stripe.auto_mount.nil?
      stripe.eager_load ||= []
      if stripe.debug_js.nil?
        stripe.debug_js = ::Rails.env.development?
      end
    end

    initializer 'stripe.configure' do |app|
      [:api_base, :verify_ssl_certs, :api_version, :open_timeout, :read_timeout].each do |key|
        value = app.config.stripe.send(key)
        Stripe.send("#{key}=", value) unless value.nil?
      end
      secret_key = app.config.stripe.secret_key
      Stripe.api_key = secret_key unless secret_key.nil?
      $stderr.puts <<-MSG unless Stripe.api_key || app.config.stripe.ignore_missing_secret_key
No stripe.com API key was configured for environment #{::Rails.env}! this application will be
unable to interact with stripe.com. You can set your API key with either the environment
variable `STRIPE_SECRET_KEY` (recommended) or by setting `config.stripe.secret_key` in your
environment file directly.
      MSG
    end

    eager_load_classes = -> class_names {
      class_names.each do |constant|
        begin
          constant.to_s.camelize.constantize
        rescue NameError
          require constant
        end
      end
    }

    initializer 'stripe.callbacks.clear_after_unload' do |app|
      # Skip Rails 4 for now.
      next unless app.respond_to?(:reloader)

      # Clear callbacks after all autoloaded classes are removed.
      # This prevents duplicate callbacks being added during development.
      app.reloader.after_class_unload do
        ::Stripe::Callbacks.clear_callbacks!
        eager_load_classes.call(app.config.stripe.eager_load)
      end
    end

    initializer 'stripe.callbacks.eager_load' do |app|
      app.config.after_initialize do
        eager_load_classes.call(app.config.stripe.eager_load)
      end
    end

    initializer 'stripe.javascript_helper' do
      ActiveSupport.on_load :action_controller do
        # ActionController::API does not have a helper method
        if respond_to?(:helper)
          helper Stripe::JavascriptHelper
        end
      end
    end

    initializer 'stripe.plans_and_coupons' do |app|
      for configuration in %w(products plans coupons prices)
        path = app.root.join("config/stripe/#{configuration}.rb")
        load path if path.exist?
      end
    end

    initializer 'stripe.assets.precompile' do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.precompile += %w( stripe_elements.js stripe_elements.css )
      end
    end

    rake_tasks do
      load 'stripe/rails/tasks.rake'
    end
  end
end
