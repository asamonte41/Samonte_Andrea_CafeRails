ActiveAdmin.register Order do
  permit_params :status

  # Add filter for customer (user)
  filter :user, as: :select, collection: proc { User.all.collect { |u| [ u.email, u.id ] } }
  filter :status
  filter :created_at

# INDEX PAGE
index do
  selectable_column
  id_column

  column "Customer" do |order|
    if order.user
      link_to order.user.email, admin_user_path(order.user)  # <-- updated line
    else
      "Guest"
    end
  end

  column :status
  column "Products Ordered" do |order|
    order.order_items.map { |oi| "#{oi.product.name} (#{oi.quantity})" }.join(", ").html_safe
  end
  column "Subtotal" do |order|
    subtotal = order.order_items.sum { |oi| oi.price_cents * oi.quantity }
    number_to_currency(subtotal / 100.0)
  end
  column "Tax" do |order|
    number_to_currency(order.tax_cents / 100.0)
  end
  column "Total" do |order|
    number_to_currency(order.total_cents / 100.0)
  end
  column :created_at
  actions
end


  # SHOW PAGE
  show do
    attributes_table do
      row :id
      row :status
      row("Customer Email") { resource.user&.email || "Guest" }
      row :created_at
      row :updated_at
    end

    if resource.user
      panel "Customer Information" do
        attributes_table_for resource.user do
          row :name
          row :email
          row :address
          row("Province") { |u| u.province&.name }
        end
      end
    end

    panel "Order Items" do
      table_for resource.order_items do
        column("Product")  { |item| item.product.name }
        column("Quantity") { |item| item.quantity }
        column("Unit Price")  { |item| number_to_currency(item.price_cents / 100.0) }
        column("Line Total")  { |item| number_to_currency((item.price_cents * item.quantity) / 100.0) }
      end
    end

    panel "Summary" do
      subtotal = resource.order_items.sum { |oi| oi.price_cents * oi.quantity }
      attributes_table_for resource do
        row("Subtotal") { number_to_currency(subtotal / 100.0) }
        row("Tax")      { number_to_currency(resource.tax_cents / 100.0) }
        row("Total")    { number_to_currency(resource.total_cents / 100.0) }
      end
    end
  end

  # FORM FOR EDITING STATUS
  form do |f|
    f.inputs "Update Order Status" do
      f.input :status, as: :select, collection: %w[new paid shipped], include_blank: false
    end
    f.actions
  end
end
