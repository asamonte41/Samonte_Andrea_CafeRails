class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :province

  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  enum :status, { new_order: "new", paid: "paid", shipped: "shipped" }, prefix: true

  # Allowlist associations for searching
  def self.ransackable_associations(auth_object = nil)
    [ "order_items", "products", "province", "user" ]
  end

  # Allowlist attributes for searching
  def self.ransackable_attributes(auth_object = nil)
    [
      "address",
      "city",
      "created_at",
      "full_name",
      "gst_cents",
      "hst_cents",
      "id",
      "payment_id",
      "postal",
      "province_id",
      "pst_cents",
      "status",
      "subtotal_cents",
      "total_cents",
      "updated_at",
      "user_id"
    ]
  end

  # Helper methods
  def subtotal
    Money.new(subtotal_cents)
  end

  def total_decimal
    total_cents.to_f / 100.0
  end

  def gst_rate
    gst_cents.to_f / 100.0
  end

  def pst_rate
    pst_cents.to_f / 100.0
  end

  def hst_rate
    hst_cents.to_f / 100.0
  end
end
