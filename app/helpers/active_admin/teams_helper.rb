module ActiveAdmin::TeamsHelper

  def team_admins_select_collection
    DiscordUser.known.order(:username).decorate
  end

end
