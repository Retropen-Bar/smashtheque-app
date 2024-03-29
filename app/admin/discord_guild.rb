ActiveAdmin.register DiscordGuild do

  decorate_with ActiveAdmin::DiscordGuildDecorator

  menu parent: '<i class="fab fa-fw fa-discord"></i>Discord'.html_safe,
       label: '<i class="fas fa-fw fa-cocktail"></i>Serveurs'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :admins, :recurring_tournaments, discord_guild_relateds: :related

  index do
    selectable_column
    id_column
    column :discord_id do |decorated|
      link_to decorated.discord_id, [:admin, decorated.model]
    end
    column :name do |decorated|
      decorated.icon_and_name(size: 32)
    end
    column :relateds do |decorated|
      decorated.relateds_admin_links
    end
    column :admins do |decorated|
      decorated.admins_admin_links(size: 32).join('<br/>').html_safe
    end
    column :recurring_tournaments do |decorated|
      decorated.recurring_tournaments_admin_links(size: 32).join('<br/>').html_safe
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all, default: true

  scope :unknown

  scope :related_to_character, group: :related
  scope :related_to_community, group: :related
  scope :related_to_player, group: :related
  scope :related_to_team, group: :related
  scope :for_recurring_tournament, group: :related

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

  action_item :fetch_broken,
              only: :index do
    link_to 'Réparer', fetch_broken_admin_discord_guilds_path, class: 'blue'
  end
  collection_action :fetch_broken do
    FetchBrokenDiscordGuildsJob.perform_later
    redirect_to request.referer, notice: 'Données en cours de réparation'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :discord_id, input_html: { disabled: f.object.persisted? }
      f.input :related_gids,
              {
                as: :select,
                collection: f.object.relateds.map do |related|
                  [
                    related&.decorate&.autocomplete_name,
                    related&.to_global_id&.to_s
                  ]
                end,
                input_html: {
                  multiple: true,
                  data: {
                    select2: {
                      ajax: {
                        url: url_for([:related_autocomplete, :admin, f.object.class]),
                        dataType: 'json'
                      }
                    }
                  }
                }
              }
      f.input :recurring_tournaments,
              collection: recurring_tournament_select_collection,
              input_html: {
                multiple: true,
                data: {
                  select2: {
                    placeholder: 'Nom de la série',
                    allowClear: true
                  }
                }
              }
      f.input :invitation_url
      discord_users_input f, :admins
      f.input :twitter_username
    end
    f.actions
  end

  permit_params :discord_id, :invitation_url, :twitter_username,
                recurring_tournament_ids: [],
                admin_ids: [], related_gids: []

  collection_action :related_autocomplete do
    render json: DiscordGuildRelated.related_autocomplete(params[:term])
  end

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
      row :relateds do |decorated|
        decorated.relateds_admin_links.join('<br/>').html_safe
      end
      row :recurring_tournaments do |decorated|
        decorated.recurring_tournaments_admin_links.join('<br/>').html_safe
      end
      row :invitation_url do |decorated|
        decorated.invitation_link
      end
      row :admins do |decorated|
        decorated.admins_admin_links(size: 32).join('<br/>').html_safe
      end
      row :twitter_username, &:twitter_link
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
