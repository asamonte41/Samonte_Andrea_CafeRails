ActiveAdmin.register Page do
  permit_params :title, :content

  form do |f|
    f.inputs "Page Details" do
      f.input :title
      f.input :content, as: :text, input_html: { rows: 10 }
    end
    f.actions
  end
end
