class MakeProvinceIdNotNullInCustomers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :customers, :province_id, false
  end
end
