class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  def price
    price_cents.to_f / 100.0
  end

  def line_total
    (price_cents * quantity).to_f / 100.0
  end
end
