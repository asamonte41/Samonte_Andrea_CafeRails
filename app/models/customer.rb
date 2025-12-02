class Customer < ApplicationRecord
  has_many :orders
  validates :name, :email, presence: true
end
