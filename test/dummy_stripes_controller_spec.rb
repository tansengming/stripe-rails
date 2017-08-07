class DummyStripesControllerTest < ApplicationSystemTestCase
  setup do
    Dummy::Application.configure do
      config.stripe.publishable_key = 'pk_test_XXXYYYZZZ'
    end
  end

  test "visiting the index" do
    visit new_stripe_url
    assert_text 'This page tests the loading of and initialization of Stripe JS'
  end
end