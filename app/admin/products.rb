ActiveAdmin.register Product do
  # Allow these parameters (including image)
  permit_params :name, :description, :price, :stock, :category_id,
                :on_sale, :new_arrival, :recently_updated, :image

  # Customize the index page
  index do
    selectable_column
    id_column
    column :image do |product|
      if product.image.attached?
        image_tag url_for(product.image), size: "50x50"
      else
        "No image"
      end
    end
    column :name
    column :category
    column :price do |product|
      number_to_currency(product.price)
    end
    column :stock
    column :on_sale
    column :new_arrival
    column :created_at
    actions
  end

  # Add filters
  filter :name
  filter :category
  filter :price
  filter :on_sale
  filter :new_arrival
  filter :created_at

  # Customize the show page
  show do
    attributes_table do
      row :id
      row :name
      row :description
      row :category
      row :price do |product|
        number_to_currency(product.price)
      end
      row :stock
      row :on_sale
      row :new_arrival
      row :recently_updated
      row :image do |product|
        if product.image.attached?
          image_tag url_for(product.image), size: "300x300"
        else
          "No image uploaded"
        end
      end
      row :created_at
      row :updated_at
    end
  end

  # Customize the form (Req 1.2 ✯, 1.3)
  form do |f|
    f.inputs "Product Details" do
      f.input :name, hint: "Enter product name (min 3 characters)"
      f.input :description, as: :text, input_html: { rows: 6 },
              hint: "Enter detailed description (min 10 characters)"
      f.input :category, as: :select, collection: Category.all.map { |c| [ c.name, c.id ] }
      f.input :price, hint: "Enter price in dollars"
      f.input :stock, hint: "Number of items in stock"
      f.input :on_sale, as: :boolean
      f.input :new_arrival, as: :boolean

      # Image upload (Req 1.3)
      if f.object.image.attached?
        f.input :image, as: :file, hint: image_tag(url_for(f.object.image), size: "200x200")
      else
        f.input :image, as: :file, hint: "No image uploaded yet"
      end
    end
    f.actions
  end
end
