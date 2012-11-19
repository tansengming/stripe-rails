module Stripe
  class Ping
    attr_reader :message

    def initialize
      @message = "Your sound card works perfectly!"
    end
  end
end