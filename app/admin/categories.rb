ActiveAdmin.register Category do
  # Allow these parameters to be updated
  permit_params :name, :description

  config.filters = false   # disables ALL filters for Category


  # Customize the index page
  index do
    selectable_column
    id_column
    column :name
    column :description do |category|
      truncate(category.description, length: 100)
    end
    column :products_count do |category|
      category.products.count
    end
    column :created_at
    actions
  end

  # Customize the show page
  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :created_at
      row :updated_at
    end

    panel "Products in this Category" do
      table_for category.products do
        column :name
        column :price do |product|
          number_to_currency(product.price)
        end
        column :stock
        column "Actions" do |product|
          link_to "View", admin_product_path(product)
        end
      end
    end
  end

  # Customize the form
  form do |f|
    f.inputs "Category Details" do
      f.input :name
      f.input :description, as: :text, input_html: { rows: 5 }
    end
    f.actions
  end
end
