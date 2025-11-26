class Category < ApplicationRecord
  has_many :products, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  # Allow Ransack to search/filter by category attributes only
  def self.ransackable_attributes(auth_object = nil)
    [ "id", "name", "description", "created_at", "updated_at" ]
  end

  # No associations needed for Ransack here
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
