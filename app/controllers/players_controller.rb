class PlayersController < PublicController
  decorates_assigned :player

  skip_before_action :verify_authenticity_token, only: :index

  around_action :skip_bullet, only: :map, if: -> { defined?(Bullet) }

  has_scope :by_character_id do |controller, scope, value|
    if controller.params[:by_character_id_mains_only] == '1'
      scope.by_main_character_id(value)
    else
      scope.by_character_id(value)
    end
  end
  has_scope :by_fr_only, type: :boolean, default: false, allow_blank: true do |_, scope, value|
    if value
      scope.by_main_countrycode_unknown_or_fr
    else
      scope.by_main_countrycode_unknown_or_french_speaking
    end
  end
  has_scope :by_team_id
  has_scope :by_community_id

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  layout 'application_v2'

  def index
    @players = players Player
    @meta_title = 'Joueurs'
  end

  def map
    @map_seconds = params[:seconds].to_i == 1
    @players = apply_scopes(Player.legit).includes(:user, :characters)
    @meta_title = 'Carte des joueurs'
  end

  def modal
    @player = Player.legit.find(params[:id])
    render :modal, layout: false
  end

  def test; end

  def recurring_tournament_contacts_index
    @players = players Player.recurring_tournament_contacts
    @meta_title = 'TOs'
    render 'recurring_tournaments/contacts', layout: 'application'
  end

  def show
    @player = Player.legit.find(params[:id])
    @online_rewards_counts = @player.rewards_counts(is_online: true)
    @offline_rewards_counts = @player.rewards_counts(is_online: false)
    @tournament_events = @player.tournament_events
                                .visible
                                .order(date: :desc)
                                .includes(
                                  recurring_tournament: :discord_guild
                                ).decorate
    @met_reward_conditions_by_tournament_event_id = Hash[
      @player.met_reward_conditions
             .includes(
               reward: {
                 image_attachment: :blob
               }
             ).map do |met_reward_condition|
        [met_reward_condition.event_id, met_reward_condition]
      end
    ]
    @all_online_rewards = Reward.online_1v1.includes(image_attachment: :blob)
    @all_offline_rewards = Reward.offline_1v1.includes(image_attachment: :blob)
    main_character = @player.characters.first&.decorate
    if main_character
      @background_color = main_character.background_color
      @background_image_url = main_character.background_image_data_url
      @background_size = main_character.background_size || 128
    end
    @meta_title = @player.name
    @meta_properties['og:type'] = 'profile'
    @meta_properties['og:image'] = @player.decorate.any_image_url
    render layout: 'application_v2'
  end

  def ranking
    @year = params[:year]&.to_i
    @year = nil unless @year&.positive?
    @is_online = params[:is_online]&.to_i != 0
    @mains_only = params[:by_character_id_mains_only]&.to_i == 1
    @fr_only = params[:by_fr_only]&.to_i == 1

    players =
      if @is_online
        if @year
          Player.ranked_online_in(@year).with_track_records_online_in(@year).order(
            "rank_online_in_#{@year}"
          )
        else
          Player.ranked_online.with_track_records_online_all_time.order(
            :rank_online_all_time
          )
        end
      elsif @year
        Player.ranked_offline_in(@year).with_track_records_offline_in(@year).order(
          "rank_offline_in_#{@year}"
        )
      else
        Player.ranked_offline.with_track_records_offline_all_time.order(
          :rank_offline_all_time
        )
      end

    @players = apply_scopes(
      players.legit
    ).includes(
      :user, :discord_user,
      :characters, :smashgg_users,
      teams: { logo_attachment: :blob }
    )

    main_character = @players.first&.characters&.first&.decorate
    if main_character
      @background_color = main_character.background_color
      @background_image_url = main_character.background_image_data_url
      @background_size = main_character.background_size || 128
    end
    @meta_title = [
      "Observatoire d'Harmonie",
      @is_online ? 'Online' : 'Offline',
      @year
    ].compact.join(' ')
    render layout: 'application'
  end

  def autocomplete
    render json: {
      results: Player.by_keyword(params[:term])
                     .includes(
                       :smashgg_users, :teams, :characters,
                       user: :discord_user
                     )
                     .limit(10)
                     .decorate
                     .map do |player|
        {
          id: player.id,
          type: :player,
          avatar: player.avatar_tag(32),
          html: player.as_autocomplete_result,
          text: player.name_and_old_names
        }
      end
    }
  end

  private

  def players(base)
    apply_scopes(
      base.legit.order(:name)
    ).includes(
      :user, :discord_user,
      :teams, :characters, :smashgg_users
    )
  end

  def current_page_params
    params.permit(
      :by_character_id, :by_character_id_mains_only,
      :by_fr_only, :by_team_id, :by_community_id,
      :seconds,
      :page, :per, :on_abc
    )
  end
end
