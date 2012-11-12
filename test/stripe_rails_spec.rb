require 'minitest/autorun'
require 'spec_helper'

describe "Configuring the stripe engine" do
  it "reads the api key that is set in the environment" do
    Stripe.api_base.must_equal 'http://localhost:5000'
    Stripe.api_key.must_equal 'XYZ'
    Stripe.verify_ssl_certs.must_equal false
  end
end

describe 'initializing plans' do
  require 'rake'
  load 'stripe-rails/tasks.rake'
  it 'creates any plans that do not exist on stripe.com' do
    Stripe::Plans.expects(:put!)
    Rake::Task['stripe:plans:prepare'].invoke
  end
end
