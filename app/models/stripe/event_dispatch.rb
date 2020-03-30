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
      endpoint_secrets = ::Rails.application.config.stripe.signing_secrets

      if Object.const_defined?('Stripe::Webhook') && sig_header && endpoint_secrets
        event = webhook_event(body, sig_header, endpoint_secrets)
      else
        event = Stripe::Event.retrieve(id)
      end

      yield event
    end

    private

    def webhook_event(body, sig_header, endpoint_secrets)
      endpoint_secrets.each_with_index do |secret, i|
        begin
          return ::Stripe::Webhook.construct_event(body, sig_header, secret.to_s)
        rescue ::Stripe::SignatureVerificationError
          raise if i == endpoint_secrets.length - 1
        end
      end
    end
  end
end