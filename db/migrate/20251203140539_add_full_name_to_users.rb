class AddFullNameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :full_name, :string

     remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string
  end
end
