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

# a--- Place Order ---
def place_order
  cart = session[:cart] || []

  # Normalize cart items (same logic as checkout)
  cart_items = cart.map do |item|
    if item.is_a?(Hash) && item.key?("product_id")
      product = Product.find_by(id: item["product_id"])
      quantity = item["quantity"].to_i
    else
      # assume item is a product ID
      product = Product.find_by(id: item)
      quantity = 1
    end

    next unless product
    { product: product, quantity: quantity }
  end.compact

  if cart_items.empty?
    flash[:alert] = "Your cart is empty."
    redirect_to cart_path
    return
  end

  # Create the order
  order = Order.new(user: current_user, status: "pending")
  if order.save
    # Add each item to the order
    cart_items.each do |item|
      order.order_items.create(
        product: item[:product],
        quantity: item[:quantity],
        unit_price_cents: (item[:product].price.to_f * 100).to_i
      )
    end

    # Clear the cart
    session[:cart] = []

    flash[:notice] = "Order placed successfully!"
    redirect_to order_path(order)
  else
    flash[:alert] = "There was a problem placing your order."
    redirect_to cart_path
  end
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

# --- Checkout ---
def checkout
  cart = session[:cart] || []  # get the cart from session

  # Normalize cart items
  @cart_items = cart.map do |item|
    if item.is_a?(Hash) && item.key?("product_id")
      product = Product.find_by(id: item["product_id"])
      quantity = item["quantity"].to_i
    else
      # assume item is a product ID
      product = Product.find_by(id: item)
      quantity = 1
    end

    next unless product  # skip if product not found

    { product: product, quantity: quantity }
  end.compact

  # Calculate subtotal in cents
  @subtotal_cents = @cart_items.sum do |item|
    (item[:product].price.to_f * 100).to_i * item[:quantity]
  end
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
