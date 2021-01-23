ActiveAdmin.register ApiToken do

  decorate_with ActiveAdmin::ApiTokenDecorator

  menu label: '<i class="fas fa-fw fa-key"></i>Tokens'.html_safe,
       parent: '<i class="fas fa-fw fa-terminal"></i>API'.html_safe

  # actions :index, :show, :new, :create, :delete

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :name
    column :token
    column :api_requests do |decorated|
      decorated.api_requests_admin_link
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :name
  filter :token

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :name
    end
    f.actions
  end

  permit_params :name

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :token
      row :api_requests do |decorated|
        decorated.api_requests_admin_link
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
