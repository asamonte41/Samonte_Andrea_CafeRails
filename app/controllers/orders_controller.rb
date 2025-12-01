class OrdersController < ApplicationController
  before_action :authenticate_user!

  # List all orders for current user
  def index
    @orders = current_user.orders.includes(order_items: :product).order(created_at: :desc)
  end

  # Show one order
  def show
    @order = current_user.orders.includes(order_items: :product).find(params[:id])
  end

  # Render invoice HTML (can later turn into printable PDF)
  def invoice
    @order = current_user.orders.find(params[:id])
  end

  ############################################################
  # NEW: Create an order before Stripe payment
  ############################################################
  def create
    province = Province.find(order_params[:province_id])

    @order = current_user.orders.build(
      status: "new",
      gst: province.gst,
      pst: province.pst,
      hst: province.hst,
      address: order_params[:address],
      city: order_params[:city],
      postal_code: order_params[:postal_code],
      province_id: province.id
    )

    # Add items from cart/session
    cart = session[:cart] || {}

    if cart.empty?
      redirect_to cart_path, alert: "Your cart is empty." and return
    end

    cart.each do |product_id, quantity|
      product = Product.find(product_id)
      @order.order_items.build(
        product: product,
        quantity: quantity,
        price: product.price
      )
    end

    if @order.save
      # User must now pay with Stripe
      redirect_to new_payment_path(order_id: @order.id)
    else
      redirect_to cart_path, alert: "Could not create order."
    end
  end

  ############################################################
  # NEW: Stripe webhook marks order as PAID
  ############################################################
  skip_before_action :verify_authenticity_token, only: [ :stripe_webhook ]

  def stripe_webhook
    event = Stripe::Event.construct_from(
      JSON.parse(request.body.read, symbolize_names: true)
    )

    if event.type == "checkout.session.completed"
      session_obj = event.data.object
      order = Order.find(session_obj.client_reference_id)

      if order.present?
        order.update(status: "paid")
      end
    end

    head :ok
  end

  private

  def order_params
    params.require(:order).permit(
      :address,
      :city,
      :postal_code,
      :province_id
    )
  end
end
