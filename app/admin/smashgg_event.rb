ActiveAdmin.register SmashggEvent do
  decorate_with ActiveAdmin::SmashggEventDecorator

  is_bracket

  menu parent: "<img src='#{SmashggEvent::ICON_URL}' height='16' class='logo'/>start.gg".html_safe,
       label: '<i class="fas fa-fw fa-chess"></i>Tournois'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :tournament_event, :duo_tournament_event,
           { top1_smashgg_user: { player: { user: :discord_user } } },
           { top2_smashgg_user: { player: { user: :discord_user } } },
           { top3_smashgg_user: { player: { user: :discord_user } } },
           { top4_smashgg_user: { player: { user: :discord_user } } },
           { top5a_smashgg_user: { player: { user: :discord_user } } },
           { top5b_smashgg_user: { player: { user: :discord_user } } },
           { top7a_smashgg_user: { player: { user: :discord_user } } },
           { top7b_smashgg_user: { player: { user: :discord_user } } }

  index do
    selectable_column
    id_column
    column :any_tournament_event do |decorated|
      decorated.any_tournament_event_admin_link
    end
    column 'Tournoi', sortable: :tournament_slug do |decorated|
      decorated.tournament_smashgg_link
    end
    column 'Événement', sortable: :slug do |decorated|
      decorated.smashgg_link
    end
    column :start_at do |decorated|
      decorated.start_at_date
    end
    column :num_entrants
    SmashggEvent::USER_NAMES.each do |user_name|
      column user_name, sortable: "#{user_name}_id".to_sym do |decorated|
        decorated.send("#{user_name}_admin_link")
      end
    end
    column :is_ignored
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :smashgg_id
  filter :tournament_name
  filter :name
  filter :slug
  filter :start_at
  filter :is_online
  filter :is_ignored
  filter :num_entrants
  filter :created_at

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :smashgg_url, placeholder: 'https://www.start.gg/...'
    end
    f.actions
  end

  permit_params :smashgg_id, :smashgg_url

  collection_action :bulk_import, method: :post do
    creations_count = 0
    (params[:smashgg_ids] || []).each do |smashgg_id|
      sleep 1 # sleep to avoid hitting API rate limits
      smashgg_event = SmashggEvent.new(smashgg_id: smashgg_id)
      if smashgg_event.import
        creations_count += 1
      else
        # do not exit on errors
        Rails.logger.debug "SmashggEvent errors: #{smashgg_event.errors.full_messages}"
      end
    end
    redirect_to request.referer, notice: "#{creations_count} imports effectués"
  end

  collection_action :import, method: :post do
    smashgg_id = params[:smashgg_id]
    smashgg_event = SmashggEvent.new(smashgg_id: smashgg_id)
    if (tournament_event = smashgg_event.import)
      redirect_to [:admin, tournament_event]
    elsif smashgg_event.persisted?
      redirect_to [:admin, smashgg_event]
    else
      redirect_to request.referer, error: 'Import impossible'
    end
  end

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    columns do
      column do
        attributes_table do
          row :smashgg_id
          row :slug
          row 'Tournoi', &:tournament_smashgg_link
          row 'Événement', &:smashgg_link
          row :tournament_owner, &:tournament_owner_admin_link
          row :discord_guild, &:discord_guild_admin_link
          row :is_online
          row :start_at
          row :num_entrants
          SmashggEvent::USER_NAMES.each do |user_name|
            row user_name do |decorated|
              decorated.send("#{user_name}_admin_link")
            end
          end
          row :tournament_event, &:tournament_event_admin_link
          row :duo_tournament_event, &:duo_tournament_event_admin_link
          row :is_ignored
          row :created_at
          row :updated_at
        end
      end
      column do
        render 'map' if resource.is_offline? && resource.geocoded?
      end
    end
  end

  # ---------------------------------------------------------------------------
  # WRONG PLAYERS
  # ---------------------------------------------------------------------------

  action_item :wrong_players, only: :index do
    errors_count = SmashggEvent.with_wrong_players.count
    link_to "Voir les #{errors_count} erreurs", { action: :wrong_players }, class: :red
  end

  collection_action :wrong_players do
    @wrong_players = SmashggEvent.wrong_players.sort_by do |data|
      [data[:smashgg_event_id], data[:rank]]
    end
  end

  # ---------------------------------------------------------------------------
  # MISSINGS
  # ---------------------------------------------------------------------------

  action_item :import_missing_smashgg_events_which_matter, only: :index do
    link_to 'Importer les tournois manquants des joueurs',
            { action: :import_missing_smashgg_events_which_matter },
            class: :blue
  end

  collection_action :import_missing_smashgg_events_which_matter do
    ImportMissingSmashggEventsWhichMatterJob.perform_later
    redirect_to request.referer, notice: 'Données en cours de récupération'
  end

  # ---------------------------------------------------------------------------
  # SEARCH
  # ---------------------------------------------------------------------------

  action_item :lookup, only: :index do
    link_to 'Rechercher sur start.gg', { action: :lookup }, class: :orange
  end

  collection_action :lookup do
    @name = params[:name]
    @from = params[:from] ? Date.parse(params[:from]) : (Date.today - 1.month)
    @to = params[:to] ? Date.parse(params[:to]) : Date.today
    # add 1 day because we are using dates and not datetimes
    @country = params[:country]
    @smashgg_events = SmashggEvent.lookup(
      name: @name,
      from: @from,
      to: @to + 1.day,
      country: @country
    )
  end

  member_action :map
end
