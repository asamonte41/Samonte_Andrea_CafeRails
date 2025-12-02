class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token

  # Stripe sends events here
  def webhook
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      return head :unauthorized
    end

    case event.type
    when "checkout.session.completed"
      session = event.data.object
      handle_checkout_completed(session)
    end

    head :ok
  end

  private

  def handle_checkout_completed(session)
    order = Order.find_by(payment_id: session.id)
    return unless order

    order.update(status: "paid")
  end
end
