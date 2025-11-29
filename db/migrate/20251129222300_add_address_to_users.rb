class AddAddressToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :address, :string
    add_column :users, :city, :string
    add_column :users, :postal, :string
    add_reference :users, :province, foreign_key: true
  end
end
