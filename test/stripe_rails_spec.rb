require 'minitest/autorun'
require 'spec_helper'

describe "Configuring the stripe engine" do
  i_suck_and_my_tests_are_order_dependent! # the default test must be run first!

  let(:app) { Dummy::Application.new }
  before { app.config.eager_load = false }

  describe 'Stripe configurations' do
    it "will have valid default values" do
      app.initialize!

      Stripe.api_base.must_equal          'https://api.stripe.com'
      Stripe.api_key.must_equal           'XYZ'
      Stripe.api_version.must_equal       nil
      Stripe.verify_ssl_certs.must_equal  true

      app.config.stripe.endpoint.must_equal   '/stripe'
      app.config.stripe.auto_mount.must_equal true
      app.config.stripe.debug_js.must_equal   false
    end

    subject do
      app.config.stripe.api_base          = 'http://localhost:5000'
      app.config.stripe.secret_key        = 'SECRET_XYZ'
      app.config.stripe.verify_ssl_certs  = false
      app.config.stripe.api_version       = '2015-10-16'
    end

    it "reads values that is set in the environment" do
      subject
      app.initialize!

      Stripe.api_base.must_equal          'http://localhost:5000'
      Stripe.api_key.must_equal           'SECRET_XYZ'
      Stripe.verify_ssl_certs.must_equal  false
      Stripe.api_version.must_equal       '2015-10-16'
    end
  end
end
