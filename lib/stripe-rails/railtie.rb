require 'stripe'

module Stripe
   class Railtie < ::Rails::Railtie
    config.stripe = Struct.new(:api_base, :api_key, :verify_ssl_certs, :publishable_key).new

    initializer 'stripe.configure.api_key', :before => 'stripe.configure' do |app|
      app.config.stripe.api_key ||= ENV['STRIPE_API_KEY']
    end

    initializer 'stripe.configure' do |app|
      [:api_base, :api_key, :verify_ssl_certs].each do |key|
        value = app.config.stripe.send(key)
        Stripe.send("#{key}=", value) unless value.nil?
      end
      warn <<-MSG unless Stripe.api_key
No stripe.com API key was configured for environment #{::Rails.env}! this application will be
unable to interact with stripe.com. You can set your API key with either the environment
variable `STRIPE_API_KEY` (recommended) or by setting `config.stripe.api_key` in your
environment file directly.
      MSG
    end
  end
end