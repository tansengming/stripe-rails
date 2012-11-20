require 'stripe/event'
module Stripe
  module EventDispatch
    def dispatch_stripe_event(params)
      retrieve_stripe_event(params) do |evt|
        ::Stripe::Callbacks.run_callbacks(evt)
      end
    end

    def retrieve_stripe_event(params)
      id = params['id']
      if id == 'evt_00000000000000' #this is a webhook test
        yield Stripe::Event.construct_from(params)
      else
        yield Stripe::Event.retrieve(id)
      end
    end
  end
end