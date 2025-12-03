class Location < ApplicationRecord
  # e.g., validations
  validates :city, presence: true

  # Explicitly allowlist searchable attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[id city created_at updated_at]
  end
end
