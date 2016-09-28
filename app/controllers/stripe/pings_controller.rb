module Stripe
  class PingsController < ::Stripe::ApplicationController
    respond_to :json

    def show
      @ping = ::Stripe::Ping.new
      respond_with @ping
    end
  end
end
