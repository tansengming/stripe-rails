ApiControllerKlass = defined?(ActionController::API) ? ActionController::API : ApplicationController

class ApisController < ApiControllerKlass
  def index
    render json: :ok
  end
end