class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :province, optional: true
  belongs_to :customer, optional: true

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
      payment_method
      stripe_payment_id
    ]
  end

  # ---- Helper Methods ----

  def subtotal_cents
    order_items.sum { |oi| oi.price_cents * oi.quantity }
  end

  def subtotal
    Money.new(subtotal_cents)
  end

  # GST: 5% for all provinces
  def gst_cents
    return 0 unless user&.province
    (subtotal_cents * 0.05).to_i
  end

  # PST: 7% for BC, SK, MB, QC
  def pst_cents
    return 0 unless user&.province
    case user.province.abbreviation
    when "BC", "SK", "MB", "QC"
      (subtotal_cents * 0.07).to_i
    else
      0
    end
  end

  # HST: 13% for ON, NB, NL, NS, PE
  def hst_cents
    return 0 unless user&.province
    case user.province.abbreviation
    when "ON", "NB", "NL", "NS", "PE"
      (subtotal_cents * 0.13).to_i
    else
      0
    end
  end

  def total_cents
    subtotal_cents + gst_cents + pst_cents + hst_cents
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

  # ---------------------------------------------------------
  #  YOUR REQUESTED ADDITIONS (nothing removed or changed)
  # ---------------------------------------------------------

  validates :full_name, :email, :address, :city, :province, presence: true
  validates :payment_method, presence: true

  def subtotal
    subtotal_cents.to_f / 100.0
  end

  def tax
    tax_cents.to_f / 100.0
  end

  def total
    total_cents.to_f / 100.0
  end

  def mark_paid!(processor:, payment_id:)
    update!(
      payment_status: "paid",
      payment_processor: processor,
      payment_id: payment_id,
      stripe_payment_id: payment_id # store Stripe payment ID here
    )
  end
end
