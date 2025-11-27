Rails.application.routes.draw do
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
