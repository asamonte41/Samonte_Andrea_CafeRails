class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :province
  belongs_to :customer

  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  # ENUM — valid statuses: "new", "paid", "shipped"
  enum :status, { new_order: "new", paid: "paid", shipped: "shipped" }, prefix: true

  # Allowlist associations for ActiveAdmin (Ransack)
  def self.ransackable_associations(_auth_object = nil)
    %w[order_items products province user]
  end

  # Allowlist attributes for ActiveAdmin
  def self.ransackable_attributes(_auth_object = nil)
    %w[
      address
      city
      created_at
      full_name
      gst_cents
      hst_cents
      id
      payment_id
      postal
      province_id
      pst_cents
      status
      subtotal_cents
      total_cents
      updated_at
      user_id
    ]
  end

  # ---- Helper Methods ----

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
