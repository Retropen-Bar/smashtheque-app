class DuosController < PublicController

  decorates_assigned :duo

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  layout :select_layout

  def index
    @duos = duos Duo
    @meta_title = 'Duos'
  end

  def show
    @duo = Duo.find(params[:id])
    @rewards_counts = @duo.rewards_counts
    @duo_tournament_events = @duo.duo_tournament_events
                                 .order(date: :desc)
                                 .includes(
                                   recurring_tournament: :discord_guild
                                 ).decorate
    @duo_reward_duo_conditions_by_duo_tournament_event_id = Hash[
      @duo.duo_reward_duo_conditions
          .includes(
            reward: {
              image_attachment: :blob
            }
          ).map do |duo_reward_duo_condition|
        [
          duo_reward_duo_condition.duo_tournament_event_id,
          duo_reward_duo_condition
        ]
      end
    ]
    @all_rewards = Reward.online_2v2.includes(image_attachment: :blob)
    # main_character = @duo.characters.first&.decorate
    # if main_character
    #   @background_color = main_character.background_color
    #   @background_image_url = main_character.background_image_data_url
    #   @background_size = main_character.background_size || 128
    # end
    @meta_title = @duo.name
    @meta_properties['og:type'] = 'profile'
  end

  def ranking_online
    @duos = apply_scopes(
      Duo.ranked.order(:rank)
    ).includes(
      player1: { user: :discord_user },
      player2: { user: :discord_user }
    )
    # main_character = @players.first.characters.first&.decorate
    # if main_character
    #   @background_color = main_character.background_color
    #   @background_image_url = main_character.background_image_data_url
    #   @background_size = main_character.background_size || 128
    # end
    @meta_title = "Observatoire d'Harmonie Online 2v2"
  end

  def ranking_online_year
    @year = params[:year].to_i
    @duos = apply_scopes(
      Duo.ranked_in(@year).order("rank_in_#{@year}")
    ).includes(
      player1: { user: :discord_user },
      player2: { user: :discord_user }
    )
    @meta_title = "Observatoire d'Harmonie Online 2v2 #{@year}"
    render 'ranking_online'
  end

  def autocomplete
    render json: {
      results: Duo.by_keyword(params[:term]).map do |duo|
        {
          id: duo.id,
          text: duo.decorate.name_with_player_names
        }
      end
    }
  end

  private

  def duos(base)
    @map = params[:map].to_i == 1
    apply_scopes(
      base.order("LOWER(name)")
    ).includes(
      player1: { user: :discord_user },
      player2: { user: :discord_user }
    )
  end

  def select_layout
    @map ? 'map' : 'application'
  end

end
