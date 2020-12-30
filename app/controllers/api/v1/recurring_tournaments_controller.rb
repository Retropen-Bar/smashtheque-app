class Api::V1::RecurringTournamentsController < Api::V1::BaseController

  has_scope :by_recurring_type_in, type: :array
  has_scope :by_wday_in, type: :array
  has_scope :by_level_in, type: :array
  has_scope :by_size_geq
  has_scope :by_size_leq

  has_scope :page, default: 1
  has_scope :per

  def index
    recurring_tournaments = apply_scopes(RecurringTournament).all
    render json: recurring_tournaments
  end

  def show
    recurring_tournament = RecurringTournament.find(params[:id])
    render json: recurring_tournament
  end

end
