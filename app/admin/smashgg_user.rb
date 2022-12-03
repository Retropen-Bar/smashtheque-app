ActiveAdmin.register SmashggUser do
  decorate_with ActiveAdmin::SmashggUserDecorator

  menu parent: "<img src='#{SmashggEvent::ICON_URL}' height='16' class='logo'/>start.gg".html_safe,
       label: '<i class="fas fa-fw fa-user"></i>Comptes'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes player: { user: :discord_user }

  index do
    selectable_column
    id_column
    column :slug do |decorated|
      decorated.smashgg_link
    end
    column :gamer_tag do |decorated|
      decorated.avatar_and_name(size: 32)
    end
    column :player do |decorated|
      decorated.player_admin_link
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all
  scope :unknown
  scope :with_player
  scope :without_player

  filter :smashgg_id
  filter :gamer_tag
  filter :slug
  filter :created_at

  action_item :fetch_unknown,
              only: :index,
              if: proc { SmashggUser.unknown.any? } do
    link_to 'Compléter', fetch_unknown_admin_smashgg_users_path, class: 'blue'
  end
  collection_action :fetch_unknown do
    SmashggUser.fetch_unknown
    redirect_to request.referer, notice: 'Données récupérées'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      unless f.object.persisted?
        f.input :smashgg_url, placeholder: 'https://www.start.gg/...'
      end
      player_input f
    end
    f.actions
  end

  permit_params :smashgg_id, :smashgg_url, :player_id

  before_create(&:fetch_smashgg_data)

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :player do |decorated|
        decorated.player_admin_link
      end
      row :smashgg_id
      row :slug do |decorated|
        decorated.smashgg_link
      end
      row :avatar do |decorated|
        unless decorated.avatar_url.blank?
          decorated.any_image_tag(size: 128)
        end
      end
      row :gamer_tag
      row :prefix
      row :name
      row :bio
      row :birthday
      row :gender_pronoun
      row :city
      row :country
      row :country_id
      row :state
      row :state_id
      row :banner_url do |decorated|
        decorated.banner_tag(max_height: 64)
      end
      row :twitch_username, &:twitch_link
      row :twitter_username, &:twitter_link
      row :discord_discriminated_username, &:discord_link
      row :created_at
      row :updated_at
    end
    panel 'Tournois placés', style: 'margin-top: 50px' do
      table_for resource.smashgg_events.admin_decorate,
                i18n: SmashggEvent do
        column :slug do |decorated|
          decorated.smashgg_link
        end
        column 'Placement' do |decorated|
          decorated.smashgg_user_rank_name(resource.id)
        end
      end
    end
  end

  action_item :fetch_smashgg_data,
              only: :show do
    link_to 'Importer les données de start.gg', [:fetch_smashgg_data, :admin, resource]
  end

  action_item :other_actions, only: :show do
    dropdown_menu 'Autres actions' do
      item 'Voir les tournois', action: :smashgg_events
      item 'Importer tous les tournois', action: :import_missing_smashgg_events
    end
  end

  member_action :fetch_smashgg_data do
    resource.fetch_smashgg_data
    if resource.save
      redirect_to [:admin, resource], notice: 'Import réussi'
    else
      flash[:error] = 'Import échoué'
      redirect_to request.referer
    end
  end

  member_action :import_missing_smashgg_events do
    resource.import_missing_smashgg_events
    redirect_to request.referer, notice: 'Import terminé'
  end

  # ---------------------------------------------------------------------------
  # EVENTS
  # ---------------------------------------------------------------------------

  member_action :smashgg_events do
    @smashgg_events = resource.fetch_smashgg_events
  end

  # ---------------------------------------------------------------------------
  # SUGGESTIONS
  # ---------------------------------------------------------------------------

  action_item :suggestions, only: %i[
    index discord_suggestions twitter_suggestions
    name_suggestions standing_suggestions] do
    dropdown_menu 'Suggestions' do
      item 'Discord', action: :discord_suggestions
      item 'Twitter', action: :twitter_suggestions
      item 'Pseudo', action: :name_suggestions
      item 'Tournoi', action: :standing_suggestions
    end
  end

  collection_action :discord_suggestions do
    @smashgg_users = SmashggUser.without_player.joins("
      INNER JOIN discord_users
              ON CONCAT(username, '#', discriminator) = discord_discriminated_username
      INNER JOIN users
              ON users.id = discord_users.user_id
      INNER JOIN players
              ON players.user_id = users.id
    ").select('smashgg_users.*, players.id AS suggested_player_id').order('unaccent(smashgg_users.gamer_tag)')

    @players = Player.where(
      id: @smashgg_users.map{|u| u['suggested_player_id']}
    ).includes(:teams, :smashgg_users, user: :discord_user).index_by(&:id)
  end

  collection_action :twitter_suggestions do
    @smashgg_users = SmashggUser.without_player.joins("
      INNER JOIN users
              ON users.twitter_username = smashgg_users.twitter_username
      INNER JOIN players
              ON players.user_id = users.id
    ").select('smashgg_users.*, players.id AS suggested_player_id').order('unaccent(smashgg_users.gamer_tag)')

    @players = Player.where(
      id: @smashgg_users.map{|u| u['suggested_player_id']}
    ).includes(:teams, :smashgg_users, user: :discord_user).index_by(&:id)
  end

  collection_action :name_suggestions do
    @smashgg_users = SmashggUser.without_player.joins("
      INNER JOIN players
              ON unaccent(players.name) ILIKE unaccent(smashgg_users.gamer_tag)
    ").select('smashgg_users.*, players.id AS suggested_player_id').order('unaccent(smashgg_users.gamer_tag)')

    @players = Player.where(
      id: @smashgg_users.map{|u| u['suggested_player_id']}
    ).includes(:teams, :smashgg_users, user: :discord_user).index_by(&:id)
  end

  collection_action :standing_suggestions do
    @smashgg_users = SmashggUser.without_player.joins("
      INNER JOIN smashgg_events
              ON smashgg_users.id IN (
                smashgg_events.top1_smashgg_user_id,
                smashgg_events.top2_smashgg_user_id,
                smashgg_events.top3_smashgg_user_id,
                smashgg_events.top4_smashgg_user_id,
                smashgg_events.top5a_smashgg_user_id,
                smashgg_events.top5b_smashgg_user_id,
                smashgg_events.top7a_smashgg_user_id,
                smashgg_events.top7b_smashgg_user_id
              )
      INNER JOIN tournament_events
              ON tournament_events.bracket_type = 'SmashggEvent' AND tournament_events.bracket_id = smashgg_events.id
      INNER JOIN players
              ON players.id IN (
                tournament_events.top1_player_id,
                tournament_events.top2_player_id,
                tournament_events.top3_player_id,
                tournament_events.top4_player_id,
                tournament_events.top5a_player_id,
                tournament_events.top5b_player_id,
                tournament_events.top7a_player_id,
                tournament_events.top7b_player_id
              )
    ").where("
      (
            smashgg_users.id = smashgg_events.top1_smashgg_user_id
        AND players.id = tournament_events.top1_player_id
      ) OR (
            smashgg_users.id = smashgg_events.top2_smashgg_user_id
        AND players.id = tournament_events.top2_player_id
      ) OR (
            smashgg_users.id = smashgg_events.top3_smashgg_user_id
        AND players.id = tournament_events.top3_player_id
      ) OR (
            smashgg_users.id = smashgg_events.top4_smashgg_user_id
        AND players.id = tournament_events.top4_player_id
      ) OR (
            smashgg_users.id IN (smashgg_events.top5a_smashgg_user_id, smashgg_events.top5b_smashgg_user_id)
        AND players.id IN (tournament_events.top5a_player_id, tournament_events.top5b_player_id)
      ) OR (
            smashgg_users.id IN (smashgg_events.top7a_smashgg_user_id, smashgg_events.top7b_smashgg_user_id)
        AND players.id IN (tournament_events.top7a_player_id, tournament_events.top7b_player_id)
      )
    ").select(
      'smashgg_users.*, players.id AS suggested_player_id, tournament_events.id AS tournament_event_id'
    ).order('unaccent(smashgg_users.gamer_tag), tournament_event_id')

    @players = Player.where(
      id: @smashgg_users.map{|u| u['suggested_player_id']}
    ).includes(:teams, :smashgg_users, user: :discord_user).index_by(&:id)
    @tournament_events = TournamentEvent.where(
      id: @smashgg_users.map{|u| u['tournament_event_id']}
    ).includes(recurring_tournament: [:discord_guild, { logo_attachment: :blob }]).index_by(&:id)
  end
end
