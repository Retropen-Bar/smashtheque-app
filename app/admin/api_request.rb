ActiveAdmin.register ApiRequest do

  decorate_with ActiveAdmin::ApiRequestDecorator

  menu label: 'Requêtes',
       parent: '<i class="fas fa-fw fa-terminal"></i>API'.html_safe

  actions :index, :show

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :api_token
    column :remote_ip
    column :controller
    column :action
    column :requested_at
    actions
  end

  filter :api_token
  filter :remote_ip
  filter :controller
  filter :action
  filter :requested_at

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :api_token
      row :remote_ip
      row :controller
      row :action
      row :requested_at
    end
  end

end
