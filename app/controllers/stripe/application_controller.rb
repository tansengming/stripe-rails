module Stripe
  class ApplicationController < ActionController::Base
    skip_before_action :verify_authenticity_token
    # is anything stripe wide?
  end
end