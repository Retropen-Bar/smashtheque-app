class DiscordGuildsController < PublicController

  has_scope :by_related_type
  has_scope :by_related_id

  def index
    base = DiscordGuild.known.order(:name)
    @character_discord_guilds = base.by_related_type(Character.to_s).to_a.sort_by do |g|
      g.relateds.map(&:name).map(&:downcase).sort.first
    end
    @player_discord_guilds = base.by_related_type(Player.to_s).to_a
    @team_discord_guilds = base.by_related_type(Team.to_s).to_a
    @location_discord_guilds = base.by_related_type(Location.to_s).to_a
    ids = @character_discord_guilds.map(&:id) +
          @player_discord_guilds.map(&:id) +
          @team_discord_guilds.map(&:id) +
          @location_discord_guilds.map(&:id)
    @other_discord_guilds = base.where.not(id: ids).to_a

    # @discord_guilds = apply_scopes(DiscordGuild.known).all
  end

  def show
    @discord_guild = DiscordGuild.find(params[:id]).decorate
  end

end
