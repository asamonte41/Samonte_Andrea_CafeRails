class AddFullNameToCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :full_name, :string, null: false, default: ""
  end
end
