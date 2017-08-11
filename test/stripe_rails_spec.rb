require 'minitest/autorun'
require 'spec_helper'

describe "Configuring the stripe engine" do
  let(:app) { Dummy::Application.new(config: Dummy::Application.config) }

  subject do
    app.config.stripe.api_base = 'http://localhost:5000'
    app.config.stripe.verify_ssl_certs = false
    app.config.stripe.api_version = '2015-10-16'
    app.config.eager_load = false
  end

  it "reads the api key that is set in the environment" do
    subject
    app.initialize!

    Stripe.api_base.must_equal          'http://localhost:5000'
    Stripe.api_key.must_equal           'XYZ'
    Stripe.api_version.must_equal       '2015-10-16'
    Stripe.verify_ssl_certs.must_equal  false
  end
end
