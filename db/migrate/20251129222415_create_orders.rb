class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true, null: true
      t.references :province, foreign_key: true, null: false

      # Customer info snapshot
      t.string :full_name
      t.string :address
      t.string :city
      t.string :postal

      # Tax & totals snapshot (in cents)
      t.integer :subtotal_cents, null: false, default: 0
      t.integer :gst_cents, null: false, default: 0
      t.integer :pst_cents, null: false, default: 0
      t.integer :hst_cents, null: false, default: 0
      t.integer :total_cents, null: false, default: 0

      # Order processing
      t.string :status, null: false, default: "new"   # new → paid → shipped
      t.string :payment_id                             # Stripe payment intent or charge ID

      t.timestamps
    end
  end
end
