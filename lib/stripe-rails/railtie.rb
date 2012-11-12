require 'stripe'

module Stripe
   class Railtie < ::Rails::Railtie
    config.stripe = Struct.new(:api_base, :api_key, :verify_ssl_certs, :publishable_key).new

    initializer 'stripe.configure' do |app|
      [:api_base, :api_key, :verify_ssl_certs].each do |key|
        value = app.config.stripe.send(key)
        Stripe.send("#{key}=", value) unless value.nil?
      end
    end
  end
end