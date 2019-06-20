module Stripe
  module EventDispatch
    def dispatch_stripe_event(request)
      retrieve_stripe_event(request) do |evt|
        target = evt.data.object
        ::Stripe::Callbacks.run_callbacks(evt, target)
      end
    end

    def retrieve_stripe_event(request)
      id = request['id']
      body = request.body.read
      sig_header = request.headers['HTTP_STRIPE_SIGNATURE']
      endpoint_secret = ::Rails.application.config.stripe.signing_secret

      if Object.const_defined?('Stripe::Webhook') && sig_header && endpoint_secret
        event = ::Stripe::Webhook.construct_event(body, sig_header, endpoint_secret)
      else
        event = Stripe::Event.retrieve(id)
      end

      yield event
    end
  end
end