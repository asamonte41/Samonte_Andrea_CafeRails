class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true, null: true
      t.string :status, null: false, default: "new"         # new, paid, shipped
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :gst_cents, null: false, default: 0
      t.integer :pst_cents, null: false, default: 0
      t.integer :hst_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0

      # address snapshot
      t.string :shipping_street
      t.string :shipping_city
      t.string :shipping_postal_code
      t.references :shipping_province, foreign_key: { to_table: :provinces }

      # payment
      t.string :payment_provider
      t.string :payment_provider_id

      t.timestamps
    end
  end
end
