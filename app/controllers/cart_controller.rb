class CartController < ApplicationController
  before_action :load_cart

  # --- Show cart ---
  def index
    @items = cart_items
    @subtotal_cents = @items.sum { |i| (i[:product].price.to_f * 100).to_i * i[:quantity] }
  end

  # --- Add item to cart ---
  def add
    product_id = params[:id].to_s
    session[:cart] ||= {}
    session[:cart][product_id] = (session[:cart][product_id] || 0) + 1
    redirect_to cart_path, notice: "Added item to cart."
  end

  # --- Update quantity ---
  def update
    product_id = params[:id].to_s
    quantity = params[:quantity].to_i
    if quantity > 0
      session[:cart][product_id] = quantity
    else
      session[:cart].delete(product_id)
    end
    redirect_to cart_path, notice: "Cart updated."
  end

  # --- Remove item ---
  def remove
    session[:cart].delete(params[:id].to_s)
    redirect_to cart_path, notice: "Item removed."
  end

  # --- Checkout redirect ---
  def checkout_redirect
    if @cart.blank?
      redirect_to cart_path, alert: "Cart is empty."
    else
      redirect_to checkout_address_path
    end
  end

  private

  # Load cart from session
  def load_cart
    session[:cart] ||= {}
    @cart = session[:cart]
  end

  # Map cart to products and quantities
  def cart_items
    @cart.map do |pid, qty|
      product = Product.find_by(id: pid)
      next unless product
      { product: product, quantity: qty.to_i }
    end.compact
  end
end
