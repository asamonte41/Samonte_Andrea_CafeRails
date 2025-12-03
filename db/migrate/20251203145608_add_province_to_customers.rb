class AddProvinceToCustomers < ActiveRecord::Migration[8.1]
  def change
    add_reference :customers, :province, foreign_key: true
  end
end
