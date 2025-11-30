class AddTotalsToOrders < ActiveRecord::Migration[7.0]
  def change
    # Only add the missing columns
    add_column :orders, :tax_cents, :integer unless column_exists?(:orders, :tax_cents)
    add_column :orders, :total_cents, :integer unless column_exists?(:orders, :total_cents)
  end
end
