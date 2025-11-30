class Province < ApplicationRecord
  has_many :orders

  # Ransack allowlist for associations
  def self.ransackable_associations(auth_object = nil)
    [ "orders" ]
  end

  # Ransack allowlist for attributes
  def self.ransackable_attributes(auth_object = nil)
    [
      "id",
      "name",
      "abbreviation",
      "created_at",
      "updated_at"
    ]
  end
end
