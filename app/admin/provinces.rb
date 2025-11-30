ActiveAdmin.register Province do
  permit_params :name, :abbreviation, :gst_cents, :pst_cents, :hst_cents

  index do
    column :name
    column :abbreviation
    column :gst_cents
    column :pst_cents
    column :hst_cents
    actions
  end
end
