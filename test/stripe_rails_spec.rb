require 'minitest/autorun'
require 'spec_helper'

describe "Configuring the stripe engine" do
  i_suck_and_my_tests_are_order_dependent! # the default test must be run first!

  let(:app) { Dummy::Application.new(config: Dummy::Application.config) }
  before { app.config.eager_load = false}

  describe 'when Stripe configurations are not changed' do
    subject { } # noop
    it "the default values will be set" do
      subject
      app.initialize!

      Stripe.api_base.must_equal          'https://api.stripe.com'
      Stripe.api_key.must_equal           'XYZ'
      Stripe.api_version.must_equal       nil
      Stripe.verify_ssl_certs.must_equal  true
    end
  end

  describe 'when Stripe configurations are changed' do
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
      Stripe.api_version.must_equal       '2015-10-16'
      Stripe.verify_ssl_certs.must_equal  false
    end
  end
end
