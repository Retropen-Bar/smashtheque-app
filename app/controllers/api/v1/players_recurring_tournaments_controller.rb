class Api::V1::PlayersRecurringTournamentsController < Api::V1::BaseController

  before_action :set_player, only: :update
  before_action :set_player_by_discord_id, only: :update_by_discord_id
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

  def update_by_discord_id
    update
  end

  private

  def set_player
    @player = Player.find(params[:player_id])
  end

  def set_player_by_discord_id
    @player = Player.by_discord_id(params[:discord_id]).first!
  end

  def set_recurring_tournament
    @recurring_tournament = RecurringTournament.find(params[:recurring_tournament_id])
  end

  def players_recurring_tournament_params
    params.require(:has_good_network)
    params.permit(
      :has_good_network, :certifier_user_id, :certifier_discord_id
    )
  end

end
