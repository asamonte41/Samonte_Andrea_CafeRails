class AddCodeToProvinces < ActiveRecord::Migration[8.1]
  def change
    add_column :provinces, :code, :string
  end
end
