ActiveAdmin.register Community do

  decorate_with ActiveAdmin::CommunityDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-map-marker-alt"></i>Communautés'.html_safe,
       parent: '<i class="fas fa-fw fa-cog"></i>Configuration'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :discord_guilds,
           logo_attachment: :blob

  index do
    selectable_column
    id_column
    column :logo do |decorated|
      decorated.logo_image_tag(max_height: 32)
    end
    column :name
    column :address
    column :countrycode, &:country_name_with_flag
    column :discord_guilds, &:discord_guilds_admin_links
    column :created_at, &:created_at_date
    actions
  end

  filter :name
  filter :address
  filter :latitude
  filter :longitude
  filter :countrycode,
         as: :select,
         collection: proc { community_countrycodes_select_collection },
         input_html: { multiple: true, data: { select2: {} } }

  action_item :map, only: :index do
    link_to 'Carte', action: :map
  end

  collection_action :map do
    @communities = Community.all
    render 'admin/communities/map'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    render 'admin/shared/google_places_api'
    columns do
      column do
        f.inputs do
          f.input :name
          f.input :logo,
                  as: :file,
                  hint: 'Laissez vide pour ne pas changer',
                  input_html: {
                    accept: 'image/*',
                    data: {
                      previewpanel: 'current-logo'
                    }
                  }
          address_input f
          users_input f, :admins
          f.input :ranking_url
          f.input :twitter_username
        end
        f.actions
      end
      column do
        panel 'Logo', id: 'current-logo' do
          f.object.decorate.logo_image_tag
        end
      end
    end
  end

  permit_params :logo, :name, :address, :latitude, :longitude, :countrycode,
                :ranking_url, :twitter_username,
                admin_ids: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :logo do |decorated|
        decorated.logo_image_tag(max_height: 64)
      end
      row :address, &:address_with_coordinates
      row :countrycode, &:country_name_with_flag
      row :ranking_url, &:ranking_link
      row :twitter_username, &:twitter_link
      row :discord_guilds, &:discord_guilds_admin_links
      row :admins do |decorated|
        decorated.admins_admin_links(size: 32).join('<br/>').html_safe
      end
      row :created_at
      row :updated_at
    end
  end

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
  end

end
