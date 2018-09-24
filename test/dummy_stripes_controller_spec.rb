require 'spec_helper'

class DummyStripesControllerSpec < ApplicationSystemTestCase
  setup do
    Dummy::Application.configure do
      config.stripe.publishable_key = 'pk_test_XXXYYYZZZ'
    end
  end

  test "loading the default javascript helper" do
    visit new_stripe_url
    assert_text 'This page tests the loading and initialization of Stripe JS'
  end

  test "loading the v2 version of the javascript helper" do
    visit new_stripe_url(version: 'v2')
    assert_text 'This page tests the loading and initialization of Stripe JS'
  end
end