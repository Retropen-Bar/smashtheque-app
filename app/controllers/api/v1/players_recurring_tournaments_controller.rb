class Api::V1::PlayersRecurringTournamentsController < Api::V1::BaseController

  before_action :set_player
  before_action :set_recurring_tournament

  def update
    players_recurring_tournament = PlayersRecurringTournament.where(
      player: @player,
      recurring_tournament: @recurring_tournament
    ).first_or_initialize
    players_recurring_tournament.attributes = players_recurring_tournament_params
    if players_recurring_tournament.save
      render json: players_recurring_tournament
    else
      render_errors players_recurring_tournament.errors, :unprocessable_entity
    end
  end

  private

  def set_player
    @player = Player.find(params[:player_id])
  end

  def set_recurring_tournament
    @recurring_tournament = RecurringTournament.find(params[:recurring_tournament_id])
  end

  def players_recurring_tournament_params
    params.permit(
      :has_good_network, :certifier_user_id
    )
  end

end
