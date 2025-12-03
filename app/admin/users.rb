ActiveAdmin.register User do
  permit_params :full_name, :email, :address, :province_id

  # FILTERS
  filter :full_name
  filter :email
  filter :province
  filter :created_at

  # INDEX PAGE
  index do
    selectable_column
    id_column
    column :full_name
    column :email
    column :address
    column("Province") { |u| u.province&.name }
    column("Orders Count") { |u| u.orders.count }

    # Show each order with its products in the index page
    column "Orders" do |user|
      user.orders.map do |order|
        "Order ##{order.id}: #{order.order_items.map { |i| i.product.name }.join(", ")}"
      end.join("<br>").html_safe
    end

    column :created_at
    actions
  end

  # SHOW PAGE
  show do
    attributes_table do
      row :id
      row :full_name
      row :email
      row :address
      row("Province") { |u| u.province&.name }
      row :created_at
      row :updated_at
    end

    panel "Orders" do
      table_for user.orders do
        column("Order ID") { |order| link_to order.id, admin_order_path(order) }
        column("Status") { |order| order.status }
        column("Products") { |order| order.order_items.map { |i| i.product.name }.join(", ") }
        column("Total") { |order| number_to_currency(order.total_cents / 100.0) }
        column("Created At") { |order| order.created_at }
      end
    end
  end

  # FORM FOR EDITING USER
  form do |f|
    f.inputs "User Details" do
      f.input :full_name
      f.input :email
      f.input :address
      f.input :province
    end
    f.actions
  end
end
