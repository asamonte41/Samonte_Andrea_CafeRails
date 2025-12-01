require "ostruct"

class CartController < ApplicationController
  before_action :load_cart

  # Show cart
  def index
    @items = @cart.map do |pid, qty|
      product = Product.find_by(id: pid)
      next unless product
      OpenStruct.new(product: product, quantity: qty)
    end.compact
  end

  # Add a product to cart
  def add
    pid = params[:id].to_s
    @cart[pid] = (@cart[pid] || 0) + 1
    redirect_back fallback_location: cart_index_path, notice: "Added to cart"
  end

  # Update quantity
  def update
    pid = params[:id].to_s
    qty = params[:quantity].to_i
    if qty > 0
      @cart[pid] = qty
    else
      @cart.delete(pid)
    end
    redirect_to cart_index_path, notice: "Cart updated"
  end

  # Remove product
  def remove
    @cart.delete(params[:id].to_s)
    redirect_to cart_index_path, notice: "Removed from cart"
  end

  # Checkout form
  def checkout
    if @cart.empty?
      redirect_to cart_index_path, alert: "Cart is empty"
      return
    end

    @customer = Customer.new
    @items = @cart.map do |pid, qty|
      product = Product.find_by(id: pid)
      OpenStruct.new(product: product, quantity: qty) if product
    end.compact

    @subtotal = @items.sum { |it| it.product.price * it.quantity }
  end

  # Place order and save order_items
  def place_order
    if @cart.empty?
      redirect_to cart_index_path, alert: "Cart is empty"
      return
    end

    # Create or find customer
    @customer = Customer.find_or_create_by(email: params[:customer][:email]) do |c|
      c.name = params[:customer][:name]
      c.province = params[:customer][:province] # string value
      c.address = params[:customer][:address]
    end

    # Ensure province_id is present
    province = Province.find_by(code: @customer.province) # assumes Province has a 'code' field
    province ||= Province.first # fallback to first province if none found

    # Build order
    order = @customer.orders.build(status: :new_order)
    order.province_id = province.id # assign NOT NULL province_id

    subtotal_cents = 0

    @cart.each do |pid, qty|
      product = Product.find_by(id: pid)
      next unless product
      price_cents = (product.price * 100).to_i
      order.order_items.build(product: product, quantity: qty, price_cents: price_cents)
      subtotal_cents += price_cents * qty
    end

    # Compute taxes
    tax_rate = calculate_tax(province.code)
    tax_cents = (subtotal_cents * tax_rate).to_i
    total_cents = subtotal_cents + tax_cents

    # Assign totals
    order.subtotal_cents = subtotal_cents
    order.total_cents = total_cents

    if order.save
      session[:cart] = {}
      redirect_to order_path(order), notice: "Order successfully placed"
    else
      flash.now[:alert] = "Failed to place order"
      render :checkout
    end
  end

  private

  def load_cart
    session[:cart] ||= {}
    @cart = session[:cart]
  end

  def calculate_tax(province_code)
    case province_code
    when "ON" then 0.13
    when "BC" then 0.12
    when "AB" then 0.05
    else 0.05
    end
  end
end
