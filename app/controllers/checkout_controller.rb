class CheckoutController < ApplicationController
  before_action :ensure_cart_present
  before_action :authenticate_user!, only: [ :create ]  # require login for saving orders; adjust for guest checkout if needed

  def address
    @user = current_user || User.new
    @provinces = Province.order(:name)
    @cart_items = load_cart_items

    # --- Auto-fill for logged-in users ---
    if current_user
      @customer = OpenStruct.new(
        full_name: current_user.email,       # or current_user.name if you have it
        address:   current_user.address,
        city:      current_user.city,
        postal:    current_user.postal,
        province:  current_user.province
      )
    else
      @customer = OpenStruct.new
    end
  end

  def summary
    # Called after address form to show invoice with taxes
    @cart_items = load_cart_items
    @address_params = params.fetch(:address, {}).permit(:full_name, :address, :city, :postal, :province_id)

    # Safely find province
    if @address_params[:province_id].present?
      @province = Province.find_by(id: @address_params[:province_id])
      unless @province
        redirect_to checkout_address_path, alert: "Please select a valid province."
        return
      end
    else
      redirect_to checkout_address_path, alert: "Province is required."
      return
    end

    compute_totals(@province)
  end

  def create
    # Create order and order_items, then redirect to payments/new
    address_params = params.require(:address).permit(:full_name, :address, :city, :postal, :province_id)
    province = Province.find_by(id: address_params[:province_id])

    unless province
      redirect_to checkout_address_path, alert: "Please select a valid province."
      return
    end

    cart_items = load_cart_items
    subtotal_cents = cart_items.sum { |ci| (ci[:product].price.to_f * 100).to_i * ci[:quantity] }

    # Compute taxes in cents
    gst_cents = province.gst_cents
    pst_cents = province.pst_cents
    hst_cents = province.hst_cents

    gst_amount_cents = (subtotal_cents * gst_cents) / 10000
    pst_amount_cents = (subtotal_cents * pst_cents) / 10000
    hst_amount_cents = (subtotal_cents * hst_cents) / 10000
    total_cents = subtotal_cents + gst_amount_cents + pst_amount_cents + hst_amount_cents

    order = Order.create!(
      user: current_user,
      province: province,
      full_name: address_params[:full_name],
      address: address_params[:address],
      city: address_params[:city],
      postal: address_params[:postal],
      subtotal_cents: subtotal_cents,
      gst_cents: gst_amount_cents,
      pst_cents: pst_amount_cents,
      hst_cents: hst_amount_cents,
      total_cents: total_cents,
      status: "new_order"
    )

    cart_items.each do |ci|
      order.order_items.create!(
        product: ci[:product],
        quantity: ci[:quantity],
        price_cents: (ci[:product].price.to_f * 100).to_i
      )
    end

    # Optionally save address to user's profile
    if current_user
      current_user.update(
        address: order.address,
        city: order.city,
        postal: order.postal,
        province: order.province
      )
    end

    # Clear cart
    session[:cart] = {}

    redirect_to new_payment_path(order_id: order.id)
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

  def compute_totals(province)
    @subtotal = load_cart_items.sum { |ci| ci[:product].price.to_f * ci[:quantity] }

    gst_rate = province.gst_cents.to_f / 100.0
    pst_rate = province.pst_cents.to_f / 100.0
    hst_rate = province.hst_cents.to_f / 100.0

    @gst = (@subtotal * gst_rate / 100.0)
    @pst = (@subtotal * pst_rate / 100.0)
    @hst = (@subtotal * hst_rate / 100.0)
    @total = @subtotal + @gst + @pst + @hst
  end
end
