class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.references :order, foreign_key: true
      t.string :provider
      t.string :provider_payment_id
      t.integer :amount_cents
      t.string :status
      t.timestamps
    end
  end
end
