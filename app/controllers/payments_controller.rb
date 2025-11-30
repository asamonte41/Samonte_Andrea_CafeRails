class PaymentsController < ApplicationController
  def new
    @order = Order.find(params[:order_id])
  end

  def create
    order = Order.find(params[:order_id])

    # create a payment intent
    intent = Stripe::PaymentIntent.create(
      amount: order.total_cents,
      currency: "cad",
      metadata: { order_id: order.id }
    )

    # For simple test flow, mark as paid immediately (in real app, use webhooks)
    order.update(status: "paid", payment_id: intent.id)

    redirect_to order_path(order), notice: "Payment recorded (test mode)."
  rescue Stripe::StripeError => e
    redirect_to new_payment_path(order_id: order.id), alert: "Payment failed: #{e.message}"
  end

  # If you want to implement webhooks later set up endpoint that updates order status on actual confirmation.
  def webhook
    # Implement only if you want real webhook handling; I won't auto-wire it here.
    head :ok
  end
end
