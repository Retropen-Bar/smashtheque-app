class DiscordGuildsController < PublicController

  has_scope :by_related_type
  has_scope :by_related_id

  def index
    @discord_guilds = apply_scopes(DiscordGuild.known).all
  end

  def show
    @discord_guild = DiscordGuild.find(params[:id]).decorate
  end

end
