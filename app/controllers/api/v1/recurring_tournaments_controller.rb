class Api::V1::RecurringTournamentsController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per

  def index
    recurring_tournaments = apply_scopes(RecurringTournament).all
    render json: recurring_tournaments
  end

end
