class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :webhook ]

  # --- Payment page ---
  def new
    @order = Order.find(params[:order_id] || session[:checkout_order_id])
  end

  # --- Inline card (test mode) ---
  def create_payment_intent
    order = Order.find(params[:order_id] || session[:checkout_order_id])
    payment_intent = Stripe::PaymentIntent.create(
      amount: order.total_cents,
      currency: order.currency || "cad",
      metadata: { order_id: order.id }
    )

    render json: { client_secret: payment_intent.client_secret }
  end

  # --- Stripe hosted checkout ---
  def create_checkout_session
    order = Order.find(params[:order_id] || session[:checkout_order_id])
    session_obj = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      mode: "payment",
      line_items: order.order_items.map do |item|
        {
          price_data: {
            currency: order.currency || "cad",
            product_data: { name: item.product_name },
            unit_amount: item.unit_price_cents
          },
          quantity: item.quantity
        }
      end,
      success_url: checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: checkout_cancel_url,
      client_reference_id: order.id
    )

    render json: { url: session_obj.url }
  end

  # --- Webhook endpoint ---
  def webhook
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      head 400 and return
    end

    case event.type
    when "payment_intent.succeeded"
      pi = event.data.object
      order = Order.find_by(id: pi.metadata.order_id)
      order&.mark_paid!(processor: "stripe", payment_id: pi.id)
    when "checkout.session.completed"
      session = event.data.object
      order = Order.find_by(id: session.client_reference_id)
      order&.mark_paid!(processor: "stripe", payment_id: session.payment_intent)
    end

    head :ok
  end
end
