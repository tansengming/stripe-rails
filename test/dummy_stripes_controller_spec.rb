begin
  require 'application_system_test_case'

  class DummyStripesControllerSpec < ApplicationSystemTestCase
    setup do
      Dummy::Application.configure do
        config.stripe.publishable_key = 'pk_test_XXXYYYZZZ'
      end
    end

    test "visiting the index" do
      visit new_stripe_url
      assert_text 'This page tests the loading and initialization of Stripe JS'
    end
  end
rescue NameError
  warn 'WARNING: System test was skipped because this Rails version does not support it!'
end