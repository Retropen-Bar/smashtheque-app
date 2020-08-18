ActiveAdmin.register Team do

  decorate_with TeamDecorator

  menu label: 'Équipes'

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :short_name
    column :name
    column :players do |decorated|
      decorated.players_link
    end
    column :created_at
    actions
  end

  filter :short_name
  filter :name

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :short_name
      f.input :name
    end
    f.actions
  end

  permit_params :short_name, :name

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :short_name
      row :name
      row :players do |decorated|
        decorated.players_link
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
