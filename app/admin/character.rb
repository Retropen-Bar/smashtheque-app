ActiveAdmin.register Character do

  decorate_with CharacterDecorator

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :name do |decorated|
      decorated.full_name
    end
    column :players do |decorated|
      decorated.players_link
    end
    column :created_at
    actions
  end

  filter :name

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :icon
      f.input :name
    end
    f.actions
  end

  permit_params :icon, :name

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :icon
      row :name
      row :players do |decorated|
        decorated.players_link
      end
      row :created_at
      row :updated_at
    end
  end

end
