require "ostruct"

class CartController < ApplicationController
  before_action :load_cart
  before_action :build_items, only: [ :index, :checkout ]

  # =========================
  # CART INDEX (VIEW CART)
  # =========================
  def index
  end

  # =========================
  # ADD ITEM TO CART
  # =========================
  def add
    pid = params[:id].to_s
    @cart[pid] = (@cart[pid] || 0) + 1

    session[:cart] = @cart
    redirect_back fallback_location: cart_index_path, notice: "Added to cart"
  end

  # =========================
  # UPDATE ITEM QUANTITY
  # =========================
  def update
    pid = params[:id].to_s
    qty = params[:quantity].to_i

    if qty > 0
      @cart[pid] = qty
    else
      @cart.delete(pid)
    end

    session[:cart] = @cart
    redirect_to cart_index_path, notice: "Cart updated"
  end

  # =========================
  # REMOVE ITEM
  # =========================
  def remove
    @cart.delete(params[:id].to_s)
    session[:cart] = @cart

    redirect_to cart_index_path, notice: "Removed from cart"
  end

  # =========================
  # CHECKOUT PAGE
  # =========================
  def checkout
    @customer = Customer.new
  end

  # =========================
  # PLACE ORDER
  # =========================
  def place_order
    if @cart.empty?
      redirect_to cart_index_path, alert: "Cart is empty"
      return
    end

    # Create or find customer
    @customer = Customer.find_or_create_by(email: customer_params[:email]) do |c|
      c.name = customer_params[:name]
      c.province = customer_params[:province]
      c.address = customer_params[:address]
    end

    # Build order
    order = @customer.orders.build(status: "pending")
    subtotal = 0

    @cart.each do |product_id, qty|
      product = Product.find_by(id: product_id)
      next unless product

      order.order_items.build(
        product: product,
        quantity: qty,
        price: product.price
      )

      subtotal += product.price * qty
    end

    tax_rate = calculate_tax(@customer.province)
    order.tax = subtotal * tax_rate
    order.total = subtotal + order.tax

    if order.save
      session[:cart] = {}
      redirect_to order_path(order), notice: "Order successfully placed"
    else
      flash.now[:alert] = "Failed to place order"
      render :checkout
    end
  end

  private

  # =========================
  # HELPERS
  # =========================

  def load_cart
    @cart = session[:cart] ||= {}
  end

  def build_items
    @items = @cart.map do |product_id, qty|
      product = Product.find_by(id: product_id)
      next unless product

      OpenStruct.new(
        product: product,
        quantity: qty,
        line_total: product.price * qty
      )
    end.compact
  end

  def customer_params
    params.require(:customer).permit(:name, :email, :province, :address)
  end

  def calculate_tax(province)
    case province
    when "ON" then 0.13
    when "BC" then 0.12
    when "AB" then 0.05
    else 0.05
    end
  end
end
