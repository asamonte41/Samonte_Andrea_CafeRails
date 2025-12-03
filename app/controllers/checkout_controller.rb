class CheckoutController < ApplicationController
  before_action :ensure_cart_present
  before_action :authenticate_user!, only: [ :create ]

  # --- Step 1: Address form ---
  def address
    @customer = current_user || OpenStruct.new
    @provinces = Province.order(:name)
    @cart_items = load_cart_items
  end

  # --- Step 2: Save address to session and go to review ---
  def process_address
    address_data = params.require(:address).permit(:full_name, :email, :address, :city, :postal, :province_id)

    if address_data.values.all?(&:present?)
      session[:checkout_address] = address_data.to_h
      redirect_to checkout_review_path
    else
      flash.now[:alert] = "Please fill in all required fields."
      @provinces = Province.order(:name)
      @cart_items = load_cart_items
      render :address
    end
  end

  # --- Step 3: Review cart and totals ---
  def review
    @cart_items = load_cart_items
    @order_data = session[:checkout_address] || {}

    @subtotal_cents = @cart_items.sum { |i| (i[:product].price.to_f * 100).to_i * i[:quantity] }

    if @order_data["province_id"].present?
      @province = Province.find_by(id: @order_data["province_id"])
      if @province
        gst_rate = @province.gst_cents.to_f / 100
        pst_rate = @province.pst_cents.to_f / 100
        hst_rate = @province.hst_cents.to_f / 100

        @gst_cents = (@subtotal_cents * gst_rate).round
        @pst_cents = (@subtotal_cents * pst_rate).round
        @hst_cents = (@subtotal_cents * hst_rate).round
        @tax_cents = @gst_cents + @pst_cents + @hst_cents
        @total_cents = @subtotal_cents + @tax_cents
      end
    end

    # fallback
    @gst_cents ||= @pst_cents ||= @hst_cents ||= @tax_cents ||= @total_cents ||= 0
  end

  # --- Step 4: Create order ---
  def create
    @cart_items = load_cart_items
    address_data = {
      full_name: params[:full_name],
      email: params[:email],
      address: params[:address],
      city: params[:city],
      postal: params[:postal],
      province_id: params[:province_id]
    }

    # validate required fields
    if address_data.values.any?(&:blank?)
      flash[:alert] = "All fields are required."
      redirect_to checkout_address_path and return
    end

    province = Province.find_by(id: address_data[:province_id])
    unless province
      flash[:alert] = "Please select a valid province."
      redirect_to checkout_address_path and return
    end

    subtotal_cents = @cart_items.sum { |ci| (ci[:product].price.to_f * 100).to_i * ci[:quantity] }
    gst_cents = (subtotal_cents * province.gst_cents.to_f / 100.0).round
    pst_cents = (subtotal_cents * province.pst_cents.to_f / 100.0).round
    hst_cents = (subtotal_cents * province.hst_cents.to_f / 100.0).round
    tax_cents = gst_cents + pst_cents + hst_cents
    total_cents = subtotal_cents + tax_cents

    ActiveRecord::Base.transaction do
      customer = if current_user
                   current_user.update(
                     full_name: address_data[:full_name],
                     email: address_data[:email],
                     address: address_data[:address],
                     city: address_data[:city],
                     postal: address_data[:postal],
                     province: province
                   )
                   current_user
      else
                   Customer.create!(
                     full_name: address_data[:full_name],
                     email: address_data[:email],
                     address: address_data[:address],
                     city: address_data[:city],
                     postal: address_data[:postal],
                     province: province
                   )
      end

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

      @cart_items.each do |ci|
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

      session[:checkout_order_id] = order.id
      session[:cart] = {}
    end

    redirect_to new_payment_path(order_id: session[:checkout_order_id])
  end

  private

  def ensure_cart_present
    redirect_to products_path, alert: "Your cart is empty" if session[:cart].blank?
  end

  def load_cart_items
    (session[:cart] || {}).map do |pid, qty|
      product = Product.find_by(id: pid)
      next unless product
      { product: product, quantity: qty.to_i }
    end.compact
  end
end
