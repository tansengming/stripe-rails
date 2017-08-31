begin
  require 'stripe_mock'
rescue LoadError
  warn %q{Please add "gem 'stripe-ruby-mock', group: 'test'"" to the Gemfile to use Stripe::Rails::Testing"}
  exit
end
require 'stripe/callbacks'

module Stripe
  module Rails
    module Testing
      def self.send_event(event, properties = {})
        evt = StripeMock.mock_webhook_event(event, properties)
        target = evt.data.object
        ::Stripe::Callbacks.run_callbacks(evt, target)
      end
    end
  end
end