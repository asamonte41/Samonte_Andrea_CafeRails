ActiveAdmin.register Customer do
  # Allow these fields to be edited
  permit_params :full_name, :email, :address, :city, :postal, :province_id

  index do
    selectable_column
    id_column
    column :full_name
    column :email
    column :address
    column :city
    column :postal
    column :province
    actions
  end

  form do |f|
    f.inputs "Customer Details" do
      f.input :full_name
      f.input :email
      f.input :address
      f.input :city
      f.input :postal
      f.input :province
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :full_name
      row :email
      row :address
      row :city
      row :postal
      row :province
      row :created_at
      row :updated_at
    end
  end
end
