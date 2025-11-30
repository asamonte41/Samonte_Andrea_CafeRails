ActiveAdmin.register Page do
  permit_params :title, :content, :slug

  index do
    column :title
    column :slug
    actions
  end

  form do |f|
    f.inputs "Page Details" do
      f.input :title
      f.input :slug, hint: "Use 'about' or 'contact'. Must be unique."
      f.input :content, as: :quill_editor # optional WYSIWYG editor
    end
    f.actions
  end
end
