class DiscordGuildsController < PublicController

  def index
    redirect_to action: :characters
  end

  def characters
    @discord_guilds = character_discord_guilds
    @meta_title = 'Serveurs Discord de personnages'
    render :index
  end

  def players
    @discord_guilds = player_discord_guilds
    @meta_title = 'Serveurs Discord de joueurs'
    render :index
  end

  def teams
    @discord_guilds = team_discord_guilds
    @meta_title = "Serveurs Discord d'équipes"
    render :index
  end

  def communities
    @discord_guilds = community_discord_guilds
    @meta_title = 'Serveurs Discord de communautés'
    render :index
  end

  def recurring_tournaments
    @discord_guilds = recurring_tournament_discord_guilds
    @meta_title = 'Serveurs Discord de tournois'
    render :index
  end

  def others
    ids = character_discord_guilds.map(&:id) +
          player_discord_guilds.map(&:id) +
          team_discord_guilds.map(&:id) +
          community_discord_guilds.map(&:id) +
          recurring_tournament_discord_guilds.map(&:id)
    @discord_guilds = base_scope.where.not(id: ids).to_a
    @meta_title = 'Autres serveurs Discord'
    render :index
  end

  private

  def base_scope
    DiscordGuild.known.order(:name)
  end

  def character_discord_guilds
    base_scope.by_related_type(Character.to_s).to_a.sort_by do |g|
      g.relateds.map(&:name).map(&:downcase).sort.first
    end
  end

  def player_discord_guilds
    base_scope.by_related_type(Player.to_s).to_a
  end

  def team_discord_guilds
    base_scope.by_related_type(Team.to_s).to_a
  end

  def community_discord_guilds
    base_scope.by_related_type(Community.to_s).to_a
  end

  def recurring_tournament_discord_guilds
    base_scope.for_recurring_tournament.to_a
  end
end
