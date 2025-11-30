ActiveAdmin.register Order do
  permit_params :status

  index do
    selectable_column
    column :id
    column :user
    column :status
    column :total_cents do |o|
      number_to_currency(o.total_cents.to_f / 100)
    end
    column :created_at
    actions
  end

  form do |f|
    f.inputs do
      f.input :status, as: :select, collection: %w[new paid shipped], include_blank: false
    end
    f.actions
  end
end
