ActiveAdmin.register DiscordUser do

  decorate_with ActiveAdmin::DiscordUserDecorator

  menu parent: '<i class="fab fa-fw fa-discord"></i>Discord'.html_safe,
       label: 'Comptes'

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :admin_user, :player

  index do
    selectable_column
    id_column
    column :discord_id
    column :username do |decorated|
      decorated.full_name(size: 32)
    end
    column :player
    column :admin_user do |decorated|
      decorated.admin_user_status
    end
    column :administrated_teams do |decorated|
      decorated.administrated_teams_admin_links(size: 32).join('<br/>').html_safe
    end
    column :administrated_discord_guilds do |decorated|
      decorated.administrated_discord_guilds_admin_links(size: 32).join('<br/>').html_safe
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all
  scope :with_admin_user
  scope :unknown

  filter :discord_id
  filter :username
  filter :discriminator
  filter :created_at

  action_item :fetch_unknown,
              only: :index,
              if: proc { DiscordUser.unknown.any? } do
    link_to 'Compléter', fetch_unknown_admin_discord_users_path, class: 'blue'
  end
  collection_action :fetch_unknown do
    FetchUnknownDiscordUsersJob.perform_later
    redirect_to request.referer, notice: 'Données en cours de récupération'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :discord_id, input_html: { disabled: f.object.persisted? }
      f.input :administrated_teams,
              collection: discord_user_administrated_teams_select_collection,
              input_html: { multiple: true, data: { select2: {} } }
      f.input :administrated_discord_guilds,
              collection: discord_user_administrated_discord_guilds_select_collection,
              input_html: { multiple: true, data: { select2: {} } }
    end
    f.actions
  end

  permit_params :discord_id, administrated_team_ids: [], administrated_discord_guild_ids: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :discord_id
      row :avatar do |decorated|
        decorated.avatar_tag
      end
      row :username do |decorated|
        decorated.discriminated_username
      end
      row :player
      row :admin_user do |decorated|
        decorated.admin_user_status
      end
      row :administrated_teams do |decorated|
        decorated.administrated_teams_admin_links(size: 32).join('<br/>').html_safe
      end
      row :administrated_discord_guilds do |decorated|
        decorated.administrated_discord_guilds_admin_links(size: 32).join('<br/>').html_safe
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

  # ---------------------------------------------------------------------------
  # AUTOCOMPLETE
  # ---------------------------------------------------------------------------

  collection_action :autocomplete do
    render json: {
      results: DiscordUser.by_keyword(params[:term]).map do |discord_user|
        {
          id: discord_user.id,
          text: discord_user.username
        }
      end
    }
  end

end
