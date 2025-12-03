class Customer < ApplicationRecord
  has_many :orders
  validates :full_name, :email, presence: true
  belongs_to :province, optional: true

  # Allowlisted Ransack associations
  def self.ransackable_associations(auth_object = nil)
    %w[orders province]
  end

  # Optional: Allowlisted Ransack attributes
  def self.ransackable_attributes(auth_object = nil)
    # Include only attributes safe for search
    column_names - %w[encrypted_password password_reset_token created_at updated_at]
  end
end
