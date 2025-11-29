class CreateProvinces < ActiveRecord::Migration[7.0]
  def change
    create_table :provinces do |t|
      t.string :name, null: false
      t.string :abbreviation, null: false
      t.integer :gst_cents, null: false, default: 0   # store rates as basis points if you like. Here we'll store percent*100 (eg 5% => 500)
      t.integer :pst_cents, null: false, default: 0
      t.integer :hst_cents, null: false, default: 0
      t.timestamps
    end
    add_index :provinces, :abbreviation, unique: true
  end
end
