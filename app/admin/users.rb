ActiveAdmin.register User do
  permit_params :name, :email, :address, :province_id

  # FILTERS
  filter :name
  filter :email
  filter :province
  filter :created_at

  # INDEX PAGE
  index do
    selectable_column
    id_column
    column :name
    column :email
    column :address
    column("Province") { |u| u.province&.name }
    column("Orders Count") { |u| u.orders.count }
    column :created_at
    actions
  end

  # SHOW PAGE
  show do
    attributes_table do
      row :id
      row :name
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
        column("Total") { |order| number_to_currency(order.total_cents / 100.0) }
        column("Created At") { |order| order.created_at }
      end
    end
  end

  # FORM FOR EDITING USER
  form do |f|
    f.inputs "User Details" do
      f.input :name
      f.input :email
      f.input :address
      f.input :province
    end
    f.actions
  end
end
