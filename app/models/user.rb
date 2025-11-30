class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :province, optional: true

  # Helper to get full address
  def full_address
    "#{address}, #{city}, #{province&.name}, #{postal}"
  end
end
