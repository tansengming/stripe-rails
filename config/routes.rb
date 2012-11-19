Rails.application.routes.draw do
  mount Stripe::Engine => Rails.application.config.stripe.endpoint
end

Stripe::Engine.routes.draw do
  resource  :ping, :only => :show
  resources :events, :only => [:create]
end