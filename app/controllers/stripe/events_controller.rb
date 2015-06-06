module Stripe
  class EventsController < ::Stripe::ApplicationController
    include Stripe::EventDispatch

    def create
      @event = dispatch_stripe_event params
      respond_with @event, :location => nil
    end
  end
end
