ActiveAdmin.register Location do
  permit_params :city   # whatever attributes are allowed for mass assignment

  filter :city_cont   # Ransack filter, this is valid here
end
