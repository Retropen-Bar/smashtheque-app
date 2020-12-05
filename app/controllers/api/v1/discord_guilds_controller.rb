class Api::V1::DiscordGuildsController < Api::V1::BaseController

  has_scope :page, default: 1
  has_scope :per

  def index
    discord_guilds = apply_scopes(DiscordGuild).all
    render json: discord_guilds
  end

end
