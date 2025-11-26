Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Root route (Req 2.1 ✯)
  root "products#index"

  # Product routes (Req 2.1 ✯, 2.3 ✯)
  resources :products, only: [ :index, :show ]

  # For later: cart, orders, etc.
end
