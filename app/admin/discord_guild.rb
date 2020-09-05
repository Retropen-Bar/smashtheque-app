ActiveAdmin.register DiscordGuild do

  decorate_with ActiveAdmin::DiscordGuildDecorator

  menu parent: '<i class="fab fa-fw fa-discord"></i>Discord'.html_safe,
       label: 'Serveurs'

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :related

  index do
    selectable_column
    id_column
    column :discord_id
    column :name do |decorated|
      decorated.full_name(size: 32)
    end
    column :related do |decorated|
      decorated.related_admin_link
    end
    column :admins do |decorated|
      decorated.admins_admin_links(size: 32).join('<br/>').html_safe
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all
  scope :unknown

  filter :discord_id
  filter :name

  action_item :fetch_unknown,
              only: :index,
              if: proc { DiscordGuild.unknown.any? } do
    link_to 'Compléter', fetch_unknown_admin_discord_guilds_path, class: 'blue'
  end
  collection_action :fetch_unknown do
    DiscordGuild.fetch_unknown
    redirect_to request.referer, notice: 'Données récupérées'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :discord_id, disabled: f.object.persisted?
      f.input :related_gid,
              as: :select,
              collection: discord_guild_related_global_select_collection,
              input_html: { data: { select2: {} } }
      f.input :invitation_url
      f.input :admins,
              collection: discord_guild_admins_select_collection,
              input_html: { multiple: true, data: { select2: {} } }
    end
    f.actions
  end

  permit_params :discord_id, :related_gid, :invitation_url, admin_ids: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :discord_id
      row :icon do |decorated|
        decorated.icon_image_tag(32)
      end
      row :name
      row :splash do |decorated|
        decorated.splash_image_tag(32)
      end
      row :related do |decorated|
        decorated.related_admin_link
      end
      row :invitation_url do |decorated|
        decorated.invitation_link
      end
      row :admins do |decorated|
        decorated.admins_admin_links(size: 32).join('<br/>').html_safe
      end
      row :created_at
      row :updated_at
    end
  end

  action_item :fetch_discord_data,
              only: :show do
    link_to 'Importer les données de Discord', [:fetch_discord_data, :admin, resource]
  end
  member_action :fetch_discord_data do
    resource.fetch_discord_data
    if resource.save
      redirect_to [:admin, resource], notice: 'Import réussi'
    else
      flash[:error] = 'Import échoué'
      redirect_to request.referer
    end
  end

end
