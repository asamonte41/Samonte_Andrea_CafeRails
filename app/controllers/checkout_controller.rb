class CheckoutController < ApplicationController
  before_action :ensure_cart_present
  before_action :authenticate_user!, only: [ :create ]

  # --- Step 1: Address form ---
  def address
    @provinces = Province.order(:name)
    @cart_items = load_cart_items

    if current_user
      # Use Customer-like struct for form defaults
      @customer_data = OpenStruct.new(
        full_name: current_user.full_name || current_user.email,
        email: current_user.email,
        address: current_user.address,
        city: current_user.city,
        postal: current_user.postal,
        province_id: current_user.province_id
      )
    else
      @customer_data = OpenStruct.new
    end
  end

  # --- Step 2: Save address to session ---
  def process_address
    permitted = params.require(:address).permit(:full_name, :email, :address, :city, :postal, :province_id)
    if permitted.values.all?(&:present?)
      session[:checkout_address] = permitted.to_h
      redirect_to checkout_review_path
    else
      flash.now[:alert] = "Please fill in all required fields."
      @provinces = Province.order(:name)
      render :address
    end
  end

  # --- Step 3: Review cart and totals ---
  def review
    @order_data = session[:checkout_address] || {}
    @cart_items = load_cart_items
    @subtotal_cents = @cart_items.sum { |i| (i[:product].price.to_f * 100).to_i * i[:quantity] }

    if @order_data["province_id"].present?
      @province = Province.find_by(id: @order_data["province_id"])
      if @province
        gst_rate = @province.gst_cents.to_f / 100.0
        pst_rate = @province.pst_cents.to_f / 100.0
        hst_rate = @province.hst_cents.to_f / 100.0

        @gst_cents = (@subtotal_cents * gst_rate).round
        @pst_cents = (@subtotal_cents * pst_rate).round
        @hst_cents = (@subtotal_cents * hst_rate).round
        @tax_cents = @gst_cents + @pst_cents + @hst_cents
        @total_cents = @subtotal_cents + @tax_cents
      else
        @gst_cents = @pst_cents = @hst_cents = @tax_cents = @total_cents = 0
      end
    end
  end

  # --- Step 4: Create order + order_items ---
  def create
    address_data = session[:checkout_address] || {}
    province = Province.find_by(id: address_data["province_id"])

    unless province
      redirect_to checkout_address_path, alert: "Please select a valid province."
      return
    end

    cart_items = load_cart_items
    if cart_items.empty?
      redirect_to products_path, alert: "Your cart is empty."
      return
    end

    subtotal_cents = cart_items.sum { |ci| (ci[:product].price.to_f * 100).to_i * ci[:quantity] }
    gst_cents = (subtotal_cents * province.gst_cents.to_f / 100.0).round
    pst_cents = (subtotal_cents * province.pst_cents.to_f / 100.0).round
    hst_cents = (subtotal_cents * province.hst_cents.to_f / 100.0).round
    tax_cents = gst_cents + pst_cents + hst_cents
    total_cents = subtotal_cents + tax_cents

    ActiveRecord::Base.transaction do
      # Find or create Customer
      customer = if current_user
                   current_user.update!(
                     full_name: address_data["full_name"],
                     email: address_data["email"],
                     address: address_data["address"],
                     city: address_data["city"],
                     postal: address_data["postal"],
                     province: province
                   )
                   current_user
      else
                   Customer.create!(
                     full_name: address_data["full_name"],
                     email: address_data["email"],
                     address: address_data["address"],
                     city: address_data["city"],
                     postal: address_data["postal"],
                     province: province
                   )
      end

      # Create Order
      order = customer.orders.create!(
        subtotal_cents: subtotal_cents,
        gst_cents: gst_cents,
        pst_cents: pst_cents,
        hst_cents: hst_cents,
        tax_cents: tax_cents,
        total_cents: total_cents,
        status: "new_order",
        payment_method: params[:payment_method] || "stripe"
      )

      # Create OrderItems
      cart_items.each do |ci|
        unit_cents = (ci[:product].price.to_f * 100).to_i
        line_total_cents = unit_cents * ci[:quantity]

        order.order_items.create!(
          product: ci[:product],
          product_name: ci[:product].name,
          unit_price_cents: unit_cents,
          quantity: ci[:quantity],
          line_total_cents: line_total_cents
        )
      end

      # Clear cart and save order id for payment
      session[:checkout_order_id] = order.id
      session[:cart] = {}
    end

    redirect_to new_payment_path(order_id: session[:checkout_order_id])
  end

  private

  def ensure_cart_present
    redirect_to products_path, alert: "Your cart is empty" if (session[:cart] || {}).empty?
  end

  def load_cart_items
    (session[:cart] || {}).map do |pid, qty|
      product = Product.find_by(id: pid)
      next unless product
      { product: product, quantity: qty.to_i }
    end.compact
  end
end
