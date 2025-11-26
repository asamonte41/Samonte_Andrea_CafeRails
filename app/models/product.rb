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

  # Scopes for filtering (Req 2.4)
  scope :on_sale, -> { where(on_sale: true) }
  scope :new_arrivals, -> { where(new_arrival: true) }
  scope :recently_updated, -> { where("updated_at >= ?", 7.days.ago) }

  # Ransack search (Req 2.6 ✯)
  def self.ransackable_attributes(auth_object = nil)
    [ "name", "description", "price", "on_sale", "new_arrival" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "category" ]
  end
end
