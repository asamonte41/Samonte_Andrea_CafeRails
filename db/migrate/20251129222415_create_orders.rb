class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true, null: true
      t.references :province, foreign_key: true, null: false

      t.string :full_name
      t.string :address
      t.string :city
      t.string :postal

      # Backup tax & totals in cents
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :gst_cents, null: false, default: 0
      t.integer :pst_cents, null: false, default: 0
      t.integer :hst_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0

      t.string :status, null: false, default: "new" # new, paid, shipped
      t.string :payment_id   # third-party payment id (e.g. stripe)

      t.timestamps
    end
  end
end
