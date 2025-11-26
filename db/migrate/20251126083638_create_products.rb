class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description
      t.decimal :price, precision: 10, scale: 2
      t.integer :stock
      t.boolean :on_sale
      t.boolean :new_arrival
      t.boolean :recently_updated
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
