class AddDetailsToCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :address, :string unless column_exists?(:customers, :address)
    add_column :customers, :city, :string unless column_exists?(:customers, :city)
    add_column :customers, :postal, :string unless column_exists?(:customers, :postal)
    add_column :customers, :province_id, :integer unless column_exists?(:customers, :province_id)
  end
end
