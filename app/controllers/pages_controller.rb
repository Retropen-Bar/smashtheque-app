class PagesController < PublicController

  before_action :set_static_page, only: %i(credits legal)

  def home
    @players_count = Rails.env.development? ? 4149 : Player.count
    @teams_count = Rails.env.development? ? 136 : Team.count
    @recurring_tournaments_count = Rails.env.development? ? 73 : RecurringTournament.count
    @tournament_events_count = Rails.env.development? ? 1050 : TournamentEvent.count
  end

  def credits
  end

  def legal
  end

  def planning_online
    @monday = Date.today.beginning_of_week
    @ics_url = recurring_tournaments_url(protocol: :webcal, format: :ics)
  end

  private

  def set_static_page
    @static = true
  end

end
