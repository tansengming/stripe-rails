require 'spec_helper'

describe "Configuring the stripe engine" do
  i_suck_and_my_tests_are_order_dependent! # the default test must be run first!

  # NOTE: skipped `stripe.plans_and_coupons` to prevent warnings about constants
  STRIPE_INITIALIZER_NAMES = %w{ stripe.configure.defaults stripe.configure stripe.callbacks.eager_load stripe.javascript_helper }

  let(:app)           { Rails.application }
  let(:initializers)  { STRIPE_INITIALIZER_NAMES.map{|name| app.initializers.find{|ini| ini.name == name } } }

  def rerun_initializers!; initializers.each{|init| init.run(app) }; end

  describe 'Stripe configurations' do
    it "will have valid default values" do
      Stripe.api_base.must_equal          'https://api.stripe.com'
      Stripe.api_key.must_equal           'XYZ'
      Stripe.api_version.must_be_nil
      Stripe.verify_ssl_certs.must_equal  true
      Stripe.open_timeout.must_equal      30
      Stripe.read_timeout.must_equal      80

      app.config.stripe.endpoint.must_equal   '/stripe'
      app.config.stripe.auto_mount.must_equal true
      app.config.stripe.debug_js.must_equal   false
    end

    subject do
      app.config.stripe.api_base          = 'http://localhost:5000'
      app.config.stripe.secret_key        = 'SECRET_XYZ'
      app.config.stripe.verify_ssl_certs  = false
      app.config.stripe.api_version       = '2015-10-16'
      app.config.stripe.open_timeout      = 33
      app.config.stripe.read_timeout      = 88
      rerun_initializers!
    end

    it "reads values that is set in the environment" do
      subject

      Stripe.api_base.must_equal          'http://localhost:5000'
      Stripe.api_key.must_equal           'SECRET_XYZ'
      Stripe.verify_ssl_certs.must_equal  false
      Stripe.api_version.must_equal       '2015-10-16'
      Stripe.open_timeout.must_equal      33
      Stripe.read_timeout.must_equal      88
    end
  end

  describe 'eager loaded callbacks' do
    subject do
      app.config.stripe.eager_load = 'dummy/model_with_callbacks', 'dummy/module_with_callbacks'
      rerun_initializers!
    end

    it 'should be eager loaded' do
      subject

      Dummy.const_defined?(:ModelWithCallbacks).must_equal  true
      Dummy.const_defined?(:ModuleWithCallbacks).must_equal true
    end
  end
end
