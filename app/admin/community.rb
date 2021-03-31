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
    column :latitude
    column :longitude
    column :discord_guilds do |decorated|
      decorated.discord_guilds_admin_links
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :name
  filter :address
  filter :latitude
  filter :longitude

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

  permit_params :logo, :name, :address, :latitude, :longitude

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :logo do |decorated|
        decorated.logo_image_tag(max_height: 64)
      end
      row :address
      row :latitude
      row :longitude
      row :discord_guilds do |decorated|
        decorated.discord_guilds_admin_links
      end
      row :created_at
      row :updated_at
    end
  end

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
  end

end
