require 'responders'

module Stripe
  class ApplicationController < ActionController::Base
    include ::ActionController::RespondWith

    respond_to :json
  end
end
