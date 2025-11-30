Rails.application.routes.draw do
  # Devise for users
  devise_for :users

  # --- Cart ---
  get "cart", to: "cart#index", as: :cart_index
  post "cart/add/:id", to: "cart#add", as: :add_cart
  patch "cart/update/:id", to: "cart#update", as: :update_cart
  delete "cart/remove/:id", to: "cart#remove", as: :remove_cart

  # --- Checkout ---
  get "checkout/address", to: "checkout#address", as: :checkout_address
  post "checkout/summary", to: "checkout#summary", as: :checkout_summary
  post "checkout/create", to: "checkout#create", as: :checkout_create

  # --- Orders ---
  resources :orders, only: [ :index, :show ]

  # --- Payments ---
  get "payments/new", to: "payments#new", as: :new_payment
  post "payments/create", to: "payments#create", as: :create_payment
  # webhook can stay GET or POST depending on your controller
  post "payments/webhook", to: "payments#webhook", as: :payments_webhook

  # --- Products ---
  resources :products, only: [ :index, :show ] do
    collection do
      get :search
      get :on_sale
      get :new_arrivals
      get :recently_updated
    end
  end

  # --- Admin ---
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # --- Root ---
  root "products#index"
end
