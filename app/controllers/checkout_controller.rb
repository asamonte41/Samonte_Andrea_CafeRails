class CheckoutController < ApplicationController
  before_action :ensure_cart_present
  before_action :authenticate_user!, only: [ :create ]  # require login to save to user/orders; adjust if you want guest checkout

  def address
    @user = current_user || User.new
    @provinces = Province.order(:name)
    @cart_items = load_cart_items
  end

  def summary
    # Called after address form to show invoice with taxes
    @cart_items = load_cart_items
    @address_params = params.require(:address).permit(:full_name, :address, :city, :postal, :province_id)
    @province = Province.find(@address_params[:province_id])
    compute_totals(@province)
  end

  def create
    # create order and order_items, then redirect to payments/new
    address_params = params.require(:address).permit(:full_name, :address, :city, :postal, :province_id)
    province = Province.find(address_params[:province_id])

    cart_items = load_cart_items
    subtotal_cents = cart_items.sum { |ci| (ci[:product].price.to_f * 100).to_i * ci[:quantity] }

    # backup tax cents from province
    gst_cents = province.gst_cents
    pst_cents = province.pst_cents
    hst_cents = province.hst_cents

    # compute tax amounts based on cents rates stored as e.g. 500 = 5.00%
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
      status: "new"
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

    # clear cart
    session[:cart] = {}

    redirect_to new_payment_path(order_id: order.id)
  end

  private

  def ensure_cart_present
    if session[:cart].blank?
      redirect_to products_path, alert: "Your cart is empty"
    end
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

    @gst = (@subtotal * (gst_rate / 100.0))
    @pst = (@subtotal * (pst_rate / 100.0))
    @hst = (@subtotal * (hst_rate / 100.0))
    @total = @subtotal + @gst + @pst + @hst
  end
end
