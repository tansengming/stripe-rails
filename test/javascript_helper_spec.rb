require 'spec_helper'

describe Stripe::JavascriptHelper do
  before { Rails.application.config.stripe.publishable_key = 'pub_xxxx' }
  let(:controller)  { ActionView::TestCase::TestController.new }
  let(:view)        { controller.view_context }

  describe '#stripe_javascript_tag' do
    describe 'when no options are passed' do
      it 'should default to v3' do
        view.stripe_javascript_tag.must_include 'https://js.stripe.com/v3/'
      end
    end

    describe 'when the v2 option is passed' do
      it 'should default to v2' do
        view.stripe_javascript_tag(:v2).must_include 'https://js.stripe.com/v2/'
      end
    end

    describe 'when the debug flag is enabled' do
      before { Rails.application.config.stripe.debug_js = true }
      after  { Rails.application.config.stripe.debug_js = false }
      it 'should render the debug js' do
        view.stripe_javascript_tag(:v1).must_include 'https://js.stripe.com/v1/stripe-debug.js'
      end

      describe 'when v3 is selected' do
        it 'should not render debug js' do
          view.stripe_javascript_tag(:v3).wont_include 'https://js.stripe.com/v1/stripe-debug.js'
        end
      end
    end
  end
end
