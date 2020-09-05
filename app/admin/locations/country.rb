ActiveAdmin.register Locations::Country do

  decorate_with ActiveAdmin::Locations::CountryDecorator

  has_paper_trail

  menu  parent: '<i class="fas fa-fw fa-map-marker-alt"></i>Localisations'.html_safe,
        label: 'Pays'

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
      decorated.players_admin_link
    end
    column :is_main
    column :discord_guilds do |decorated|
      decorated.discord_guilds_admin_links
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :name
  filter :is_main

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :icon
      f.input :name
      f.input :is_main
    end
    f.actions
  end

  permit_params :icon, :name, :is_main

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :icon
      row :name
      row :players do |decorated|
        decorated.players_admin_link
      end
      row :is_main
      row :discord_guilds do |decorated|
        decorated.discord_guilds_admin_links
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  action_item :make_city,
              only: :show do
    link_to 'Transformer en ville', [:make_city, :admin, resource], class: 'green'
  end
  member_action :make_city do
    resource.update_attribute :type, 'Locations::City'
    redirect_to admin_locations_city_path(resource)
  end

end
