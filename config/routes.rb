Rails.application.routes.draw do
  # --- Devise for Users ---
  # Uses a custom registrations controller
  devise_for :users, controllers: { registrations: "users/registrations" }

  # --- Pages ---
  get "/pages/:slug", to: "pages#show", as: "page"

  # --- Cart ---
  get    "cart",                to: "cart#index",  as: :cart
  post   "cart/add/:id",        to: "cart#add",    as: :add_cart
  patch  "cart/update/:id",     to: "cart#update", as: :update_cart
  delete "cart/remove/:id",     to: "cart#remove", as: :remove_cart

  # Cart checkout redirects
  get  "cart/checkout",      to: "cart#checkout",        as: :checkout_cart
  post "cart/place_order",   to: "cart#place_order",     as: :place_order_cart

  # --- Checkout flow (address → review → create) ---
  get  "checkout/address",         to: "checkout#address",         as: :checkout_address
  post "checkout/process_address", to: "checkout#process_address", as: :checkout_process_address
  get  "checkout/review",          to: "checkout#review",          as: :checkout_review
  post "checkout/create",          to: "checkout#create",          as: :checkout_create

  # --- Customer Dashboard ---
  get "dashboard", to: "dashboard#index", as: :dashboard

  # --- Orders ---
  resources :orders, only: [ :index, :show ] do
    member do
      get :invoice
    end
  end

  # --- Payments ---
  get  "payments/new",                     to: "payments#new",                     as: :new_payment
  post "payments/create",                  to: "payments#create",                  as: :create_payment
  get  "payments/selection",               to: "payments#selection",               as: :payment_selection
  post "payments/create_payment_intent",   to: "payments#create_payment_intent"
  post "payments/create_checkout_session", to: "payments#create_checkout_session"
  post "payments/webhook",                 to: "payments#webhook",                 as: :payments_webhook
  post "/stripe/webhook",                  to: "stripe#webhook"

  # --- Products ---
  resources :products, only: [ :index, :show ] do
    collection do
      get :search
      get :on_sale
      get :new_arrivals
      get :recently_updated
    end
  end

  # --- Admin (ActiveAdmin) ---
  # Place AFTER Devise for :users to prevent conflicts
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # --- Root ---
  root to: "products#index"
end
