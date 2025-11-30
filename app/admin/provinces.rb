ActiveAdmin.register Province do
  permit_params :name, :abbreviation

  index do
    column :name
    column :abbreviation
    actions
  end

  # Optional: filters
  filter :name
  filter :abbreviation
end
