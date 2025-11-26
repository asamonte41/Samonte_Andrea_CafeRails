class Page < ApplicationRecord
  # Validations (optional)
  validates :title, :content, presence: true

  # Ransack allowlisted attributes for search/filter
  def self.ransackable_attributes(auth_object = nil)
    %w[id title content created_at updated_at]
  end
end
