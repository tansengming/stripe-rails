module Stripe
  class EventsController < ApplicationController
    respond_to :json

    def create
      @event = Stripe::Event.dispatch params
      respond_with @event, :location => nil
    end
  end
end