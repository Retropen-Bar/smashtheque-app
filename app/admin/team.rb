ActiveAdmin.register Team do

  decorate_with ActiveAdmin::TeamDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-users"></i>Équipes'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :short_name
    column :name do |decorated|
      decorated.full_name_with_logo(max_height: 32)
    end
    column :is_offline
    column :is_online
    column :is_sponsor
    column :players do |decorated|
      decorated.players_admin_link
    end
    column :admins do |decorated|
      decorated.admins_admin_links(size: 32).join('<br/>').html_safe
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :short_name
  filter :name
  filter :is_offline
  filter :is_online
  filter :is_sponsor

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :short_name
      f.input :name
      f.input :logo_url
      f.input :is_offline
      f.input :is_online
      f.input :is_sponsor
      f.input :admins,
              collection: team_admins_select_collection,
              input_html: { multiple: true, data: { select2: {} } }
      f.input :twitter_username
    end
    f.actions
  end

  permit_params :short_name, :name, :logo_url, :twitter_username,
                :is_offline, :is_online, :is_sponsor,
                admin_ids: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :short_name
      row :name
      row :logo_url do |decorated|
        decorated.logo_image_tag(max_height: 64)
      end
      row :is_offline
      row :is_online
      row :is_sponsor
      row :players do |decorated|
        decorated.players_admin_link
      end
      row :admins do |decorated|
        decorated.admins_admin_links(size: 32).join('<br/>').html_safe
      end
      row :discord_guilds do |decorated|
        decorated.discord_guilds_admin_links
      end
      row :twitter_username do |decorated|
        decorated.twitter_link
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
