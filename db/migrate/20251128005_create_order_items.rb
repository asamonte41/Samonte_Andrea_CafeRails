class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.references :order, foreign_key: true, null: false
      t.references :product, foreign_key: true, null: false
      t.integer :quantity, null: false, default: 1

      # snapshot
      t.integer :unit_price_cents, null: false   # product price at time of checkout (in cents)
      t.integer :line_total_cents, null: false   # unit_price_cents * quantity
      t.timestamps
    end
  end
end
