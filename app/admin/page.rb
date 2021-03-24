ActiveAdmin.register Page do

  decorate_with ActiveAdmin::PageDecorator

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :slug do |decorated|
      link_to decorated.slug, [:admin, decorated.model]
    end
    column :name do |decorated|
      link_to decorated.name, [:admin, decorated.model]
    end
    column :parent do |decorated|
      decorated.parent_admin_link
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :slug
  filter :name
  filter :parent

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :slug
      f.input :name
      f.input :parent,
              collection: page_parent_select_collection,
              input_html: {
                data: {
                  select2: {
                    placeholder: 'Page parente',
                    allowClear: true
                  }
                }
              },
              include_blank: "Aucune"
      f.input :content, as: :action_text
    end
    f.actions
  end

  permit_params :slug, :name, :parent_id, :content

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :slug
      row :name
      row :parent do |decorated|
        decorated.parent_admin_link
      end
      row :content do |decorated|
        decorated.formatted_content
      end
      row :children do |decorated|
        decorated.children_admin_links.join('<br/>').html_safe
      end
      row :created_at
      row :updated_at
    end
  end

end
