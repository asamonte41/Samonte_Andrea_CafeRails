class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :province

  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  enum status: { new: "new", paid: "paid", shipped: "shipped" }

  def subtotal
    Money.new(subtotal_cents) # if using money gem, otherwise return cents / 100.0
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
