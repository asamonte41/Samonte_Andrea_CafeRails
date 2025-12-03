require "ostruct"

class CartController < ApplicationController
  before_action :load_cart

  # --- Show cart ---
  def index
    @items = cart_items
  end

  # --- Add / Update / Remove actions (unchanged) ---
  # ... existing add, update, remove code ...

  # --- Checkout form ---
  def checkout
    if @cart.empty?
      redirect_to cart_index_path, alert: "Cart is empty" and return
    end

    @customer = Customer.new
    @items = cart_items
    @subtotal = @items.sum { |it| it.product.price * it.quantity }
  end

  # --- Place order ---
  def place_order
    if @cart.empty?
      redirect_to cart_index_path, alert: "Cart is empty" and return
    end

    @items = cart_items
    @subtotal = @items.sum { |it| it.product.price.to_f * it.quantity }

    # Validate full name
    full_name = params.dig(:customer, :full_name).presence
    if full_name.blank?
      flash.now[:alert] = "Full name is required"
      render :checkout and return
    end

    # Find or create customer
    @customer = Customer.find_or_initialize_by(email: params.dig(:customer, :email))
    @customer.full_name   = full_name
    @customer.address     = params.dig(:customer, :address)
    @customer.city        = params.dig(:customer, :city)
    @customer.postal      = params.dig(:customer, :postal)
    @customer.province_id = Province.find_by(code: params.dig(:customer, :province_code))&.id || Province.first.id
    @customer.save!

    province = Province.find(@customer.province_id)

    # Build order + order_items
    order = @customer.orders.build(status: :new_order, province_id: province.id)
    subtotal_cents = 0

    @cart.each do |pid, qty|
      product = Product.find_by(id: pid)
      next unless product

      unit_cents = (product.price.to_f * 100).to_i
      line_total_cents = unit_cents * qty

      order.order_items.build(
        product: product,
        product_name: product.name,
        quantity: qty,
        unit_price_cents: unit_cents,
        line_total_cents: line_total_cents
      )
      subtotal_cents += line_total_cents
    end

    # Taxes
    tax_rate = calculate_tax(province.code)
    tax_cents = (subtotal_cents * tax_rate).to_i
    total_cents = subtotal_cents + tax_cents

    # Assign totals
    order.subtotal_cents = subtotal_cents
    order.tax_cents      = tax_cents
    order.total_cents    = total_cents
    order.payment_method = nil # not yet selected

    if order.save
      session[:cart] = {}
      session[:checkout_order_id] = order.id

      # ✅ Redirect to Payment Selection page instead of a payment method
      redirect_to payment_selection_path(order_id: order.id), notice: "Order successfully placed. Please select a payment method."
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

  def cart_items
    @cart.map do |pid, qty|
      product = Product.find_by(id: pid)
      OpenStruct.new(product: product, quantity: qty) if product
    end.compact
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
