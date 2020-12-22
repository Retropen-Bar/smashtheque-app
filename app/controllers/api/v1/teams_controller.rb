class Api::V1::TeamsController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc
  has_scope :by_short_name_like

  def index
    teams = apply_scopes(Team).all
    render json: teams
  end

  def show
    team = Team.find(params[:id])
    render json: team
  end

  def update
    team = Team.find(params[:id])

    attributes = team_params

    if attributes[:short_name] != team.short_name
      existing_other_teams = Team.by_short_name_like(attributes[:short_name]).pluck(:id)
      if existing_other_teams.any?
        render_errors({ short_name: :already_known, existing_ids: existing_other_teams }, :unprocessable_entity) and return
      end
    end

    team.attributes = attributes
    if team.save
      render json: team
    else
      render_errors team.errors, :unprocessable_entity
    end
  end

  private

  def team_params
    params.require(:team).permit(%i(
      name short_name twitter_username
      is_offline is_online is_sponsor
      logo logo_url roster roster_url
    ))
  end

end
