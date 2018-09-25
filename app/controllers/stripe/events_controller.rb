module Stripe
  class EventsController < ::Stripe::ApplicationController
    include Stripe::EventDispatch
    respond_to :json

    def create
      @event = dispatch_stripe_event(request)
      head :ok
    rescue JSON::ParserError => e
      ::Rails.logger.error e.message
      head :bad_request, status: 400
    rescue Stripe::SignatureVerificationError => e
      ::Rails.logger.error e.message
      head :bad_request, status: 400
    end
  end
end
