class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      # Snapshot of price and quantity
      t.integer :quantity, null: false, default: 1
      t.integer :price_cents, null: false, default: 0  # price at time of checkout

      t.timestamps
    end
  end
end
