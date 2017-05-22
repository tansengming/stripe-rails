require 'stripe_mock'
require 'stripe/callbacks'

module Stripe
  module Testing
    def self.send_event(event, properties = {})
      evt = StripeMock.mock_webhook_event(event, properties)
      target = evt.data.object
      ::Stripe::Callbacks.run_callbacks(evt, target)
    end
  end
end