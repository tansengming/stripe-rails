Rails.application.routes.draw do
  if Rails.application.config.stripe.auto_mount
    mount Stripe::Engine => Rails.application.config.stripe.endpoint
  end
end

Stripe::Engine.routes.draw do
  resources :events, only: :create
end
