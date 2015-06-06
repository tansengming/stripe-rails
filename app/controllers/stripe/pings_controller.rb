module Stripe
  class PingsController < ::Stripe::ApplicationController
    def show
      @ping = Ping.new
      respond_with @ping
    end
  end
end
