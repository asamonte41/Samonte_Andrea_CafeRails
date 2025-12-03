class Customer < ApplicationRecord
  has_many :orders
  validates :full_name, :email, presence: true
  belongs_to :province, optional: true
end
