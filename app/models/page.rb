class Page < ApplicationRecord
  # Validations
  validates :title, :content, :slug, presence: true
  validates :slug, uniqueness: true

  # Ransack allowlist for searchable attributes
  def self.ransackable_attributes(auth_object = nil)
    %w[id title content slug created_at updated_at]
  end

  # Ransack allowlist for associations
  def self.ransackable_associations(auth_object = nil)
    [] # no associations to search
  end
end
