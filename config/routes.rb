Rails.application.routes.draw do
  get "payments/new"
  get "payments/create"
  get "payments/webhook"
  get "orders/index"
  get "orders/show"
  get "checkout/address"
  get "checkout/summary"
  get "checkout/create"
  get "cart/index"
  get "cart/add"
  get "cart/update"
  get "cart/remove"
  devise_for :users

# Cart
get "cart", to: "cart#index", as: :cart_index
post "cart/add/:id", to: "cart#add", as: :add_cart
patch "cart/update/:id", to: "cart#update", as: :update_cart
delete "cart/remove/:id", to: "cart#remove", as: :remove_cart

# Checkout
get "checkout/address", to: "checkout#address", as: :checkout_address
post "checkout/summary", to: "checkout#summary", as: :checkout_summary
post "checkout/create", to: "checkout#create", as: :checkout_create

# Orders
resources :orders, only: [ :index, :show ]

# Payments
get "payments/new", to: "payments#new", as: :new_payment
post "payments/create", to: "payments#create", as: :create_payment

# Root and products
root to: "products#index"
resources :products, only: [ :index, :show ]



  # --- ADMIN (unchanged) ---
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)





  # --- PUBLIC STORE FRONT ---

  # Root route → product list (Req 2.1)
  root "products#index"

  # Product browsing (Req 2.1, 2.3, 2.4, 2.6)
  resources :products, only: [ :index, :show ] do
    collection do
      get :search        # /products/search?q=...
      get :on_sale       # /products/on_sale
      get :new_arrivals  # optional if needed
      get :recently_updated
    end
  end

  # (future) cart, orders, checkout
end
