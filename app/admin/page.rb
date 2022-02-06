ActiveAdmin.register Page do

  decorate_with ActiveAdmin::PageDecorator

  menu label: '<i class="fas fa-fw fa-paragraph"></i>Pages'.html_safe

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
    column :is_draft
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all, default: true
  scope :draft
  scope :published

  filter :slug
  filter :name
  filter :parent
  filter :is_draft
  filter :in_header
  filter :in_footer

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :slug
      f.input :name
      f.input :is_draft
      f.input :in_header
      f.input :in_footer
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
              include_blank: 'Aucune'
      f.input :content, as: :action_text
    end
    f.actions
  end

  permit_params :slug, :name,
                :is_draft, :in_header, :in_footer, :parent_id,
                :content

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :slug
      row :name
      row :is_draft
      row :in_header
      row :in_footer
      row :parent, &:parent_admin_link
      row :content, &:formatted_content
      row :children do |decorated|
        decorated.children_admin_links.join('<br/>').html_safe
      end
      row :created_at
      row :updated_at
    end
  end

end
