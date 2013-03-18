require 'minitest/autorun'
require 'spec_helper'

describe "Configuring the stripe engine" do
  it "reads the api key that is set in the environment" do
    Stripe.api_base.must_equal 'http://localhost:5000'
    Stripe.api_key.must_equal 'XYZ'
    Stripe.verify_ssl_certs.must_equal false
  end
end
