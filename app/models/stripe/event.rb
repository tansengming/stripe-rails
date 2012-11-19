require 'stripe/event'
module Stripe
  class Event
    def self.dispatch(params)
      Stripe::Event.retrieve(params['id']).tap do |evt|
        ::Stripe::Callbacks.run_callbacks(evt)
      end
    end
  end
end