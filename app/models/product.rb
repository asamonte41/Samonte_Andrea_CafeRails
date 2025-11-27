class Product < ApplicationRecord
  belongs_to :category

  # Active Storage for images (Req 1.3)
  has_one_attached :image

  # Validations (Req 4.2.1 ✯)
  validates :name, presence: true, length: { minimum: 3, maximum: 255 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :category, presence: true

  # ---------------------------------------------------------
  # Public Storefront Scopes (Req 2.4)
  # ---------------------------------------------------------

  # On sale filter
  scope :on_sale, -> { where(on_sale: true) }

  # New products (created within last N days) — default 3
  scope :new_within, ->(days = 3) {
    where("created_at >= ?", days.to_i.days.ago)
  }

  # Recently updated, excluding new products
  scope :recently_updated_within, ->(days = 3) {
    where("updated_at >= ?", days.to_i.days.ago)
      .where.not("created_at >= ?", days.to_i.days.ago)
  }

  # Filter by category
  scope :by_category, ->(category_id) {
    where(category_id: category_id) if category_id.present?
  }

  # Keyword search for public site (NOT used by ActiveAdmin)
  scope :keyword_search, ->(q) {
    where("LOWER(name) LIKE :q OR LOWER(description) LIKE :q",
      q: "%#{q.to_s.downcase}%") if q.present?
  }

  # ---------------------------------------------------------
  # ActiveAdmin RANSACK (no changes!)
  # ---------------------------------------------------------
  # These must remain for ActiveAdmin to search properly
  def self.ransackable_attributes(auth_object = nil)
    [ "name", "description", "price", "on_sale", "new_arrival" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "category" ]
  end
end
