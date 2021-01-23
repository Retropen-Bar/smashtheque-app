ActiveAdmin.register Locations::City do

  decorate_with ActiveAdmin::Locations::CityDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-city"></i>Villes'.html_safe,
       parent: '<i class="fas fa-fw fa-cog"></i>Configuration'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :discord_guilds

  index do
    selectable_column
    id_column
    column :name do |decorated|
      decorated.full_name
    end
    column :latitude
    column :longitude
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

  scope :all, default: true

  scope :not_geocoded, group: :geocoded
  scope :geocoded, group: :geocoded

  action_item :map, only: :index do
    link_to 'Carte', map_admin_locations_cities_path
  end

  collection_action :map do
    @locations = Locations::City.all
    render 'admin/locations/map'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :icon
      f.input :name
      f.input :is_main
      address_input f,
                    {
                      componentRestrictions: {
                        country: :fr
                      }
                    }
    end
    f.actions
  end

  permit_params :icon, :name, :is_main, :latitude, :longitude

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :icon
      row :name
      row :latitude
      row :longitude
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

  action_item :make_country,
              only: :show do
    link_to 'Transformer en pays', [:make_country, :admin, resource], class: 'green'
  end
  member_action :make_country do
    resource.update_attribute :type, 'Locations::Country'
    redirect_to admin_locations_country_path(resource)
  end

end
