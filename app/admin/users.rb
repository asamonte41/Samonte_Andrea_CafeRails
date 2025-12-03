ActiveAdmin.register User do
  # Permit parameters for assignment
  permit_params :email, :full_name, :address, :city, :postal, :province_id, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :full_name
    column :email
    column :address
    column :city
    column :postal
    column :province
    column :created_at
    actions
  end

  filter :full_name
  filter :email
  filter :city
  filter :province
  filter :created_at

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs "User Details" do
      f.input :full_name
      f.input :email
      f.input :address
      f.input :city
      f.input :postal
      f.input :province
      f.input :password
      f.input :password_confirmation
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
