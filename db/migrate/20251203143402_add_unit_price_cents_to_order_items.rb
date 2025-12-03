class AddUnitPriceCentsToOrderItems < ActiveRecord::Migration[8.1]
  def change
    add_column :order_items, :unit_price_cents, :integer
  end
end
