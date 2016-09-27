require 'stripe/event'
module Stripe
  module EventDispatch
    def dispatch_stripe_event(params)
      retrieve_stripe_event(params) do |evt|
        target = extract_stripe_target(evt)
        ::Stripe::Callbacks.run_callbacks(evt, target)
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

    def extract_stripe_target(event)
      object_params = event.data["object"]
      object_name   = object_params["object"]
      object_class  = ::Stripe.const_get(object_name.classify) rescue nil
      target        = object_class.construct_from(object_params) if object_class
      target ||= object_params
    end
  end
end
