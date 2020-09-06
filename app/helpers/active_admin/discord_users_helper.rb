module ActiveAdmin::DiscordUsersHelper

  def discord_user_administrated_discord_guilds_select_collection
    DiscordGuild.known.order(:name).decorate
  end

  def discord_user_administrated_teams_select_collection
    Team.order(:name).decorate
  end

end
