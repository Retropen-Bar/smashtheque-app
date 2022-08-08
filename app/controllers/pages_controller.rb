class PagesController < PublicController
  before_action :set_static_page, only: %i[show]

  decorates_assigned :page

  layout 'application_v2' 

  def home
    @players_count = Rails.env.development? ? 4149 : Player.count
    @teams_count = Rails.env.development? ? 136 : Team.count
    @recurring_tournaments_count = Rails.env.development? ? 73 : RecurringTournament.count
    @tournament_events_count = Rails.env.development? ? 1050 : TournamentEvent.count
  end

  def show
    @page = Page.find_by!(slug: params[:slug])
    @in_header = @page.in_header
    @meta_title = @page.name
  end

  private

  def set_static_page
    @static = true
  end
end
