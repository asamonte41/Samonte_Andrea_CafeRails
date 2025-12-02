class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # Converts stored cents to decimal price
  def price
    price_cents.to_f / 100.0
  end

  # Total price for this line item
  def line_total
    (price_cents * quantity).to_f / 100.0
  end

  # Ransack allowlist for associations
  def self.ransackable_associations(auth_object = nil)
    [ "order", "product" ]
  end

  # Ransack allowlist for attributes
  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "order_id",
      "product_id",
      "quantity",
      "price_cents",
      "created_at",
      "updated_at"
    ]
  end
end
