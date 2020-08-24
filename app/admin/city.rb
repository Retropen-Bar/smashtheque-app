ActiveAdmin.register City do

  decorate_with CityDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-map-marker-alt"></i>Villes'.html_safe

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
    column :created_at do |decorated|
      decorated.created_at_date
    end
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
    active_admin_comments
  end

end
