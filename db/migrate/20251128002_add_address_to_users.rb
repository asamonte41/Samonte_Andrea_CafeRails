class AddAddressToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :street, :string
    add_column :users, :city, :string
    add_column :users, :postal_code, :string
    add_reference :users, :province, foreign_key: true
  end
end
