class DuosController < PublicController
  decorates_assigned :duo

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  layout 'application_v2'

  def index
    @duos = duos Duo
    @meta_title = 'Duos'
  end

  def show
    @duo = Duo.find(params[:id])
    @online_rewards_counts = @duo.rewards_counts(is_online: true)
    @offline_rewards_counts = @duo.rewards_counts(is_online: false)
    @duo_tournament_events = @duo.duo_tournament_events
                                 .visible
                                 .order(date: :desc)
                                 .includes(
                                   recurring_tournament: :discord_guild
                                 ).decorate
    @met_reward_conditions_by_duo_tournament_event_id = Hash[
      @duo.met_reward_conditions
          .includes(
            reward: {
              image_attachment: :blob
            }
          ).map do |met_reward_condition|
        [
          met_reward_condition.event_id,
          met_reward_condition
        ]
      end
    ]
    @all_online_rewards = Reward.online_2v2.includes(image_attachment: :blob)
    @all_offline_rewards = Reward.offline_2v2.includes(image_attachment: :blob)
    @meta_title = @duo.name
    @meta_properties['og:type'] = 'profile'
  end

  def ranking
    @year = params[:year]&.to_i
    @year = nil unless @year&.positive?
    @is_online = params[:is_online]&.to_i != 0

    @duos = apply_scopes(
      Duo.ranking(is_online: @is_online, year: @year)
    ).includes(
      player1: { user: :discord_user },
      player2: { user: :discord_user }
    )

    @meta_title = [
      "Observatoire d'Harmonie 2v2",
      @is_online ? 'Online' : 'Offline',
      @year
    ].compact.join(' ')
    render layout: 'application'
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
    apply_scopes(
      base.order('LOWER(name)')
    ).includes(
      player1: { user: :discord_user },
      player2: { user: :discord_user }
    )
  end
end
