require 'spec_helper'

describe "Configuring the stripe engine" do
  i_suck_and_my_tests_are_order_dependent! # the default test must be run first!

  # NOTE: skipped `stripe.plans_and_coupons` to prevent warnings about constants
  STRIPE_INITIALIZER_NAMES = %w{ stripe.configure.defaults stripe.configure stripe.callbacks.eager_load stripe.javascript_helper }

  let(:app)           { Rails.application }
  let(:initializers)  { STRIPE_INITIALIZER_NAMES.map{|name| app.initializers.find{|ini| ini.name == name } } }

  def rerun_initializers!; initializers.each{|init| init.run(app) }; end

  after do
    Stripe.api_version       = nil
    Stripe.api_base          = 'https://api.stripe.com'
    Stripe.api_key           = 'XYZ'
    ENV['STRIPE_SECRET_KEY'] = 'XYZ'
  end

  describe 'Stripe configurations' do
    it "will have valid default values" do
      _(Stripe.api_base).must_equal          'https://api.stripe.com'
      _(Stripe.api_key).must_equal           'XYZ'
      _(Stripe.api_version).must_be_nil
      _(Stripe.verify_ssl_certs).must_equal  true
      _(Stripe.open_timeout).must_equal      30
      _(Stripe.read_timeout).must_equal      80

      _(app.config.stripe.endpoint).must_equal   '/stripe'
      _(app.config.stripe.auto_mount).must_equal true
      _(app.config.stripe.debug_js).must_equal   false
    end

    subject do
      app.config.stripe.api_base          = 'http://localhost:5000'
      app.config.stripe.secret_key        = 'SECRET_XYZ'
      app.config.stripe.signing_secret    = 'SIGNING_SECRET_XYZ'
      app.config.stripe.verify_ssl_certs  = false
      app.config.stripe.api_version       = '2015-10-16'
      app.config.stripe.open_timeout      = 33
      app.config.stripe.read_timeout      = 88
      rerun_initializers!
    end

    it "reads values that is set in the environment" do
      subject

      _(Stripe.api_base).must_equal          'http://localhost:5000'
      _(Stripe.api_key).must_equal           'SECRET_XYZ'
      _(Stripe.verify_ssl_certs).must_equal  false
      _(Stripe.api_version).must_equal       '2015-10-16'
      _(Stripe.open_timeout).must_equal      33
      _(Stripe.read_timeout).must_equal      88

      _(app.config.stripe.signing_secret).must_equal 'SIGNING_SECRET_XYZ'
      _(app.config.stripe.signing_secrets.length).must_equal 1
    end

    it "supports nil signing_secret" do
      subject

      app.config.stripe.signing_secret    = nil
      rerun_initializers!

      _(app.config.stripe.signing_secret).must_equal nil
      _(app.config.stripe.signing_secrets).must_equal nil
    end

    it "supports multiple signing secrets" do
      subject

      app.config.stripe.signing_secrets    = ['SIGNING_SECRET_XYZ', 'SIGNING_SECRET_XYZ_CONNECT']
      rerun_initializers!

      _(app.config.stripe.signing_secret).must_equal 'SIGNING_SECRET_XYZ'
      _(app.config.stripe.signing_secrets.length).must_equal 2
    end

  end

  describe 'eager loaded callbacks' do
    subject do
      app.config.stripe.eager_load = 'dummy/model_with_callbacks', 'dummy/module_with_callbacks'
      rerun_initializers!
    end

    it 'should be eager loaded' do
      subject

      _(Dummy.const_defined?(:ModelWithCallbacks)).must_equal  true
      _(Dummy.const_defined?(:ModuleWithCallbacks)).must_equal true
    end
  end

  describe 'setting stripe.api_key' do
    subject { app.config.stripe.api_key = 'XYZ' }
    let(:warning_msg) { "[DEPRECATION] to align with stripe nomenclature, stripe.api_key has been renamed to config.stripe.secret_key\n" }

    it 'should output a warning' do
      _(-> { subject }).must_output '', warning_msg
    end
  end

  describe 'missing stripe.secret_key' do
    subject do
      ENV['STRIPE_SECRET_KEY'] = nil
      Stripe.api_key = nil
      app.config.stripe.secret_key = nil
      rerun_initializers!
    end
    let(:warning_msg) { /No stripe.com API key was configured for environment test!/ }

    it 'should output a warning' do
      _(-> { subject }).must_output '', warning_msg
    end
  end

  describe 'stripe.ignore_missing_secret_key' do
    subject do
      ENV['STRIPE_SECRET_KEY'] = nil
      Stripe.api_key = nil
      app.config.stripe.secret_key = nil
      app.config.stripe.ignore_missing_secret_key = true
      rerun_initializers!
    end

    after do
      app.config.stripe.ignore_missing_secret_key = false
    end

    it 'should not output a warning' do
      _(-> { subject }).must_output '', ''
    end
  end
end
