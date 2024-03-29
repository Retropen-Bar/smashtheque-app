ActiveAdmin.register TournamentEvent do
  decorate_with ActiveAdmin::TournamentEventDecorator

  sidebar 'Autres éditions', only: :show do
    div class: 'tournament-events-nav-links' do
      resource.events_nav_links
    end
  end

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess"></i>Compétition'.html_safe,
       label: '<i class="fas fa-fw fa-chess-rook"></i>Éditions 1v1'.html_safe,
       priority: 1

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  order_by(:bracket) do |order_clause|
    if order_clause.order == 'desc'
      'bracket_type DESC, bracket_id DESC'
    else
      'bracket_type, bracket_id'
    end
  end

  includes :recurring_tournament, :bracket,
           top1_player: [:smashgg_users, { user: :discord_user }],
           top2_player: [:smashgg_users, { user: :discord_user }],
           top3_player: [:smashgg_users, { user: :discord_user }],
           top4_player: [:smashgg_users, { user: :discord_user }],
           top5a_player: [:smashgg_users, { user: :discord_user }],
           top5b_player: [:smashgg_users, { user: :discord_user }],
           top7a_player: [:smashgg_users, { user: :discord_user }],
           top7b_player: [:smashgg_users, { user: :discord_user }]

  index do
    selectable_column
    id_column
    column :recurring_tournament
    column :name do |decorated|
      link_to decorated.name, [:admin, decorated.model]
    end
    column :date
    column :bracket_url, &:bracket_icon_link
    column :bracket, sortable: :bracket, &:bracket_admin_link
    column :is_online, &:online?
    column :participants_count
    TournamentEvent::TOP_NAMES.each do |player_name|
      column player_name do |decorated|
        decorated.send("#{player_name}_admin_link")
      end
    end
    column :is_complete
    column :is_out_of_ranking
    actions
  end

  scope :all, default: true

  scope :without_recurring_tournament, group: :missing
  scope :with_missing_graph, group: :missing
  scope :with_missing_players, group: :missing
  scope :with_missing_data, group: :missing

  scope :on_smashgg, group: :bracket
  scope :on_braacket, group: :bracket
  scope :on_challonge, group: :bracket

  scope :online, group: :location
  scope :offline, group: :location

  filter :recurring_tournament
  filter :name
  filter :date
  filter :bracket_url
  filter :participants_count
  filter :is_complete
  filter :is_out_of_ranking

  collection_action :update_available_brackets do
    UpdateAvailableBracketsJob.perform_later
    redirect_to request.referer, notice: 'Données en cours de récupération'
  end

  collection_action :use_available_players do
    TournamentEvent.use_available_players
    redirect_to request.referer, notice: 'Joueurs ajoutés'
  end

  action_item :other_actions, only: :index do
    dropdown_menu 'Autres actions' do
      if (available_brackets_count = TournamentEvent.with_available_bracket.count)
        item "Récupérer les #{available_brackets_count} brackets disponibles",
             action: :update_available_brackets
      end
      if (with_available_players_count = TournamentEvent.with_available_players.count)
        item "Ajouter les #{with_available_players_count} joueurs disponibles",
             action: :use_available_players
      end
    end
  end

  batch_action :set_recurring_tournament, form: -> {
    {
      I18n.t('activerecord.models.recurring_tournament') => (
        [['Aucune', '']] + RecurringTournament.order('LOWER(name)').pluck(:name, :id)
      )
    }
  } do |ids, inputs|
    recurring_tournament_id = inputs[I18n.t('activerecord.models.recurring_tournament')]
    unless recurring_tournament_id.blank?
      recurring_tournament = RecurringTournament.find(recurring_tournament_id)
    end
    batch_action_collection.where(id: ids).each do |event|
      event.recurring_tournament = recurring_tournament
      event.save!
    end
    redirect_to request.referer, notice: 'Éditions mises à jour'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    columns do
      column do
        panel 'Bracket' do
          f.inputs do
            f.input :bracket_url
            f.input :bracket_gid,
                    {
                      as: :select,
                      collection: [
                        [
                          f.object.bracket&.decorate&.autocomplete_name,
                          f.object.bracket&.to_global_id&.to_s
                        ]
                      ],
                      input_html: {
                        data: {
                          select2: {
                            ajax: {
                              url: url_for(action: :bracket_autocomplete),
                              dataType: 'json'
                            },
                            placeholder: 'Nom du bracket',
                            allowClear: true
                          }
                        }
                      }
                    }
          end
        end
        panel 'Graph', id: 'current-graph' do
          f.object.decorate.graph_image_tag
        end
        panel '' do
          f.input :graph,
                  as: :file,
                  label: 'Nouveau graph',
                  hint: 'Laissez vide pour ne pas changer',
                  input_html: {
                    accept: 'image/*',
                    data: {
                      previewpanel: 'current-graph'
                    }
                  }
        end
      end
      column do
        panel 'Informations' do
          f.inputs do
            f.input :recurring_tournament,
                    collection: recurring_tournament_select_collection,
                    input_html: {
                      data: {
                        select2: {
                          placeholder: 'Nom de la série',
                          allowClear: true
                        }
                      }
                    },
                    include_blank: 'Aucun'
            f.input :name
            f.input :date
            f.input :participants_count
            TournamentEvent::TOP_NAMES.each do |player_name|
              hint = f.object.decorate.send("#{player_name}_bracket_suggestion")
              player_input f, name: player_name, hint: hint
            end
            f.input :is_online, hint: "Seulement si le tournoi n'appartient pas à une série"
            f.input :is_complete
            f.input :is_out_of_ranking
          end
          f.actions
        end
      end
    end
  end

  permit_params :name, :date, :recurring_tournament_id, :participants_count,
                :top1_player_id, :top2_player_id, :top3_player_id,
                :top4_player_id, :top5a_player_id, :top5b_player_id,
                :top7a_player_id, :top7b_player_id,
                :is_online, :is_complete, :is_out_of_ranking,
                :bracket_url, :bracket_gid,
                :graph

  collection_action :bracket_autocomplete do
    render json: TournamentEvent.bracket_autocomplete(params[:term])
  end

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    columns do
      column do
        attributes_table do
          row :recurring_tournament
          row :name
          row :date
          row :participants_count
          row :bracket_url, &:bracket_link
          TournamentEvent::TOP_NAMES.each do |player_name|
            row player_name do |decorated|
              decorated.send("#{player_name}_admin_link")
            end
          end
          row :is_online, &:online?
          row :is_complete
          row :is_out_of_ranking
          row :bracket, &:bracket_admin_link
          row :created_at
          row :updated_at
        end
        panel 'Récompenses obtenues', style: 'margin-top: 50px' do
          table_for resource.met_reward_conditions.admin_decorate,
                    i18n: MetRewardCondition do
            column :reward_condition, &:reward_condition_admin_link
            column :awarded, &:awarded_admin_link
            column :reward, &:reward_admin_link
            column :points
          end
        end
      end
      column do
        panel 'Graph' do
          resource.graph_image_tag(max_width: '100%')
        end
      end
    end
    active_admin_comments
  end

  action_item :other_actions, only: :show do
    dropdown_menu 'Autres actions' do
      if can?(:complete_with_bracket, resource)
        item 'Compléter avec start.gg', action: :complete_with_bracket if resource.is_on_smashgg?
        item 'Compléter avec Braacket', action: :complete_with_bracket if resource.is_on_braacket?
        item 'Compléter avec Challonge', action: :complete_with_bracket if resource.is_on_challonge?
      end
      if can?(:compute_rewards, resource)
        item 'Recalculer les récompenses', action: :compute_rewards
      end
      if resource.graph.attached? && can?(:purge_graph, resource)
        item 'Supprimer le graph', action: :purge_graph
      end
      if can?(:convert_to_duo_tournament_event, resource)
        item 'Convertir en édition 2v2', action: :convert_to_duo_tournament_event
      end
    end
  end

  member_action :purge_graph do
    resource.graph.purge
    redirect_to request.referer, notice: 'Graph supprimé'
  end

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
  end

  member_action :complete_with_bracket do
    if resource.complete_with_bracket && resource.save
      redirect_to request.referer, notice: 'Données mises à jour'
    else
      Rails.logger.debug "Model errors: #{resource.errors.full_messages}"
      Rails.logger.debug "Bracket errors: #{resource.bracket&.errors&.full_messages}"
      flash[:error] = 'Mise à jour échouée'
      redirect_to request.referer
    end
  end

  member_action :compute_rewards do
    resource.compute_rewards
    redirect_to request.referer, notice: 'Calcul effectué'
  end

  member_action :convert_to_duo_tournament_event do
    duo_tournament_event = resource.convert_to_duo_tournament_event
    if duo_tournament_event
      redirect_to [:admin, duo_tournament_event], notice: 'Conversion effectuée'
    else
      flash[:error] = 'Conversion échouée'
      redirect_to request.referer
    end
  end

  # ---------------------------------------------------------------------------
  # DUPLICATES
  # ---------------------------------------------------------------------------

  action_item :potential_duplicates, only: :index do
    link_to 'Vérifier les doublons', { action: :potential_duplicates }, class: :blue
  end

  collection_action :potential_duplicates do
    @potential_duplicates = TournamentEvent.potential_duplicates
  end

  member_action :not_duplicates, method: :post do
    resource.not_duplicates = resource.not_duplicates + [params[:not_duplicate_id]]
    if resource.save
      head :ok
    else
      head :unprocessable_entity
    end
  end

  # ---------------------------------------------------------------------------
  # SUGGESTIONS
  # ---------------------------------------------------------------------------

  action_item :suggestions, only: %i[
    index
    discord_suggestions location_suggestions
    admin_owner_suggestions owner_owner_suggestions
  ] do
    dropdown_menu 'Suggestions' do
      item 'Discord', action: :discord_suggestions
      item 'Localisation', action: :location_suggestions
      item 'TO de la série', action: :admin_owner_suggestions
      item 'TO d\'une édition', action: :owner_owner_suggestions
      # other ideas:
      # - one word in common in name
    end
  end

  collection_action :discord_suggestions do
    @name = params[:name].presence

    @tournament_events = TournamentEvent.without_recurring_tournament.joins(
      <<-SQL.squish
      INNER JOIN smashgg_events
              ON smashgg_events.id = bracket_id AND bracket_type = 'SmashggEvent'
      INNER JOIN recurring_tournaments
              ON recurring_tournaments.discord_guild_id = smashgg_events.discord_guild_id
      SQL
    ).where(
      'tournament_events.name ILIKE ?', @name || '%%'
    ).select(
      <<-SQL.squish
      tournament_events.*,
      recurring_tournaments.id AS suggested_recurring_tournament_id,
      recurring_tournaments.discord_guild_id AS suggested_recurring_tournament_discord_guild_id
      SQL
    ).includes(
      :recurring_tournament,
      bracket: :tournament_owner
    ).order('unaccent(tournament_events.name)').page(params[:page] || 1).per(25)

    @recurring_tournaments = RecurringTournament.where(
      id: @tournament_events.map { |e| e['suggested_recurring_tournament_id'] }
    ).includes(:discord_guild, logo_attachment: :blob).index_by(&:id)
    @discord_guilds = DiscordGuild.where(
      id: @tournament_events.map { |e| e['suggested_recurring_tournament_discord_guild_id'] }
    ).index_by(&:id)
  end

  collection_action :location_suggestions do
    @name = params[:name].presence

    @tournament_events = TournamentEvent.without_recurring_tournament.joins(
      <<-SQL.squish
      INNER JOIN smashgg_events
              ON smashgg_events.id = bracket_id AND bracket_type = 'SmashggEvent'
      INNER JOIN recurring_tournaments
              ON (
                   recurring_tournaments.latitude BETWEEN (smashgg_events.latitude - 0.01) AND (smashgg_events.latitude + 0.01)
                 ) AND (
                   recurring_tournaments.longitude BETWEEN (smashgg_events.longitude - 0.01) AND (smashgg_events.longitude + 0.01)
                 )
      SQL
    ).where(
      'tournament_events.name ILIKE ?', @name || '%%'
    ).where.not(is_online: true).where(
      # we ignore:
      # - <46.227638, 2.213749> which is the location of "France"
      # - <37.09024, -95.712891> which is the location of "United States"
      <<-SQL.squish
      smashgg_events.latitude IS NOT NULL AND smashgg_events.longitude IS NOT NULL
      AND (smashgg_events.latitude != 46.227638 OR smashgg_events.longitude != 2.213749)
      AND (smashgg_events.latitude != 37.09024 OR smashgg_events.longitude != -95.712891)
      AND recurring_tournaments.latitude IS NOT NULL AND recurring_tournaments.longitude IS NOT NULL
      AND (recurring_tournaments.latitude != 46.227638 OR recurring_tournaments.longitude != 2.213749)
      AND (recurring_tournaments.latitude != 37.09024 OR recurring_tournaments.longitude != -95.712891)
      SQL
    ).select(
      <<-SQL.squish
      tournament_events.*,
      recurring_tournaments.id AS suggested_recurring_tournament_id
      SQL
    ).includes(
      :recurring_tournament,
      bracket: :tournament_owner
    ).order('unaccent(tournament_events.name)').page(params[:page] || 1).per(25)

    @recurring_tournaments = RecurringTournament.where(
      id: @tournament_events.map { |e| e['suggested_recurring_tournament_id'] }
    ).includes(:discord_guild, logo_attachment: :blob).index_by(&:id)
  end

  collection_action :admin_owner_suggestions do
    @name = params[:name].presence

    @tournament_events = TournamentEvent.without_recurring_tournament.joins(
      <<-SQL.squish
      INNER JOIN smashgg_events
              ON smashgg_events.id = bracket_id AND bracket_type = 'SmashggEvent'
      INNER JOIN smashgg_users
              ON smashgg_users.id = smashgg_events.tournament_owner_id
      INNER JOIN players
              ON players.id = smashgg_users.player_id
      INNER JOIN users
              ON users.id = players.user_id
      INNER JOIN recurring_tournament_contacts
              ON recurring_tournament_contacts.user_id = users.id
      SQL
    ).where(
      'tournament_events.name ILIKE ?', @name || '%%'
    ).select(
      <<-SQL.squish
      tournament_events.*,
      recurring_tournament_contacts.recurring_tournament_id AS suggested_recurring_tournament_id,
      users.id AS suggested_recurring_tournament_contact_user_id,
      smashgg_users.id AS suggested_recurring_tournament_contact_smashgg_user_id
      SQL
    ).includes(
      :recurring_tournament,
      bracket: :tournament_owner
    ).order('unaccent(tournament_events.name)').page(params[:page] || 1).per(25)

    @recurring_tournaments = RecurringTournament.where(
      id: @tournament_events.map { |e| e['suggested_recurring_tournament_id'] }
    ).includes(:discord_guild, logo_attachment: :blob).index_by(&:id)
    @users = User.where(
      id: @tournament_events.map { |e| e['suggested_recurring_tournament_contact_user_id'] }
    ).includes(:discord_user).index_by(&:id)
    @smashgg_users = SmashggUser.where(
      id: @tournament_events.map { |e| e['suggested_recurring_tournament_contact_smashgg_user_id'] }
    ).index_by(&:id)
  end

  collection_action :owner_owner_suggestions do
    @name = params[:name].presence

    recurring_tournament_owners =
      <<-SQL.squish
      SELECT recurring_tournament_id,
             tournament_owner_id,
             min(tournament_events.id) AS example_tournament_event_id
      FROM tournament_events
      INNER JOIN smashgg_events
              ON bracket_type = 'SmashggEvent' AND smashgg_events.id = bracket_id
      WHERE recurring_tournament_id IS NOT NULL
        AND tournament_owner_id IS NOT NULL
      GROUP BY recurring_tournament_id, tournament_owner_id
      SQL

    @tournament_events = TournamentEvent.without_recurring_tournament.joins(
      <<-SQL.squish
      INNER JOIN smashgg_events
              ON smashgg_events.id = bracket_id AND bracket_type = 'SmashggEvent'
      INNER JOIN (#{recurring_tournament_owners}) recurring_tournament_owners
              ON smashgg_events.tournament_owner_id = recurring_tournament_owners.tournament_owner_id
      SQL
    ).where(
      'tournament_events.name ILIKE ?', @name || '%%'
    ).select(
      <<-SQL.squish
      tournament_events.*,
      recurring_tournament_owners.recurring_tournament_id AS suggested_recurring_tournament_id,
      recurring_tournament_owners.example_tournament_event_id AS example_tournament_event_id
      SQL
    ).includes(
      :recurring_tournament,
      bracket: :tournament_owner
    ).order('unaccent(tournament_events.name)').page(params[:page] || 1).per(25)

    @recurring_tournaments = RecurringTournament.where(
      id: @tournament_events.map { |e| e['suggested_recurring_tournament_id'] }
    ).includes(:discord_guild, logo_attachment: :blob).index_by(&:id)
    @example_tournament_events = TournamentEvent.where(
      id: @tournament_events.map { |e| e['example_tournament_event_id'] }
    ).includes(:recurring_tournament, bracket: :tournament_owner).index_by(&:id)
  end
end
