class RetropenBot

  # ---------------------------------------------------------------------------
  # CONSTANTS
  # ---------------------------------------------------------------------------

  CATEGORY_ABC = 'JOUEURS FR : ABÉCÉDAIRE'.freeze
  CHANNEL_ABC_OTHERS = 'symboles-0-9'.freeze
  CATEGORY_CHARS1 = 'JOUEURS FR : ROSTER A-M'.freeze
  CATEGORY_CHARS2 = 'JOUEURS FR : ROSTER N-Z'.freeze
  CATEGORY_CITIES = 'JOUEURS FR : VILLES MAJEURES'.freeze
  CATEGORY_COUNTRIES = 'JOUEURS FR : PAYS MAJEURS'.freeze
  CATEGORY_TEAMS = 'ÉQUIPES FR'.freeze
  CHANNEL_TEAMS_LIST = 'listing-équipes'.freeze
  CHANNEL_TEAMS_LU = 'roster-équipes'.freeze

  # ---------------------------------------------------------------------------
  # CONSTRUCTOR
  # ---------------------------------------------------------------------------

  def initialize(guild_id: nil)
    @guild_id = guild_id || ENV['DISCORD_GUILD_ID']
  end

  def self.default
    @default ||= new
  end

  # ---------------------------------------------------------------------------
  # SHARED
  # ---------------------------------------------------------------------------

  def client
    @client ||= DiscordClient.new
  end

  # ---------------------------------------------------------------------------
  # ABC
  # ---------------------------------------------------------------------------

  def self.name_letter(name)
    return nil if name.blank?
    I18n.transliterate(name.first).downcase
  end

  def abc_category
    client.find_or_create_guild_category @guild_id, name: CATEGORY_ABC
  end

  def rebuild_abc_letter(letter, abc_category_id = nil)
    abc_channel = find_or_create_readonly_channel @guild_id,
                                                  name: letter,
                                                  parent_id: abc_category_id || abc_category['id']

    rebuild_channel_with_players abc_channel['id'],
                                 Player.on_abc(letter)
  end

  def rebuild_abc_others(abc_category_id = nil)
    abc_others_channel = find_or_create_readonly_channel @guild_id,
                                                         name: CHANNEL_ABC_OTHERS,
                                                         parent_id: abc_category_id || abc_category['id']
    rebuild_channel_with_players abc_others_channel['id'],
                                 Player.on_abc_others
  end

  def rebuild_abc_for_letter(letter, abc_category_id = nil)
    if ('a'..'z').include?(letter)
      rebuild_abc_letter letter, abc_category_id
    else
      rebuild_abc_others abc_category_id
    end
  end

  # ---------------------------------------------------------------------------
  # CHARS
  # ---------------------------------------------------------------------------

  def chars_category1
    client.find_or_create_guild_category @guild_id, name: CATEGORY_CHARS1
  end

  def chars_category2
    client.find_or_create_guild_category @guild_id, name: CATEGORY_CHARS2
  end

  def rebuild_chars_for_character(character, chars_category1_id: nil, chars_category2_id: nil)
    return false if character.nil?
    letter = self.class.name_letter character.name
    parent_category_id = if ('a'..'m').include?(letter)
      chars_category1_id || chars_category1['id']
    else
      chars_category2_id || chars_category2['id']
    end
    channel_name = [character.icon, character.name.parameterize].join
    channel = find_or_create_readonly_channel @guild_id,
                                              name: channel_name,
                                              parent_id: parent_category_id
    rebuild_channel_with_players channel['id'],
                                 character.players
  end

  # ---------------------------------------------------------------------------
  # LOCATIONS
  # ---------------------------------------------------------------------------

  def cities_category
    client.find_or_create_guild_category @guild_id, name: CATEGORY_CITIES
  end

  def countries_category
    client.find_or_create_guild_category @guild_id, name: CATEGORY_COUNTRIES
  end

  def rebuild_locations_for_location(location, cities_category_id: nil, countries_category_id: nil)
    return false if location.nil?
    return false unless location.is_main?
    parent_category_id = if location.is_a?(Locations::Country)
      countries_category_id || countries_category['id']
    else
      cities_category_id || cities_category['id']
    end
    channel_name = [location.icon, location.name.parameterize].join
    channel = find_or_create_readonly_channel @guild_id,
                                              name: channel_name,
                                              parent_id: parent_category_id
    rebuild_channel_with_players channel['id'],
                                 location.players
  end

  # ---------------------------------------------------------------------------
  # TEAMS
  # ---------------------------------------------------------------------------

  def teams_category
    client.find_or_create_guild_category @guild_id, name: CATEGORY_TEAMS
  end

  def teams_list_channel(teams_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_TEAMS_LIST,
                                    parent_id: teams_category_id || teams_category['id']
  end

  def teams_lu_channel(teams_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_TEAMS_LU,
                                    parent_id: teams_category_id || teams_category['id']
  end

  def rebuild_teams_list(_teams_category_id = nil)
    teams_category_id = _teams_category_id || teams_category['id']
    lines = Team.order(:name).map do |team|
      [
        team.short_name,
        team.name
      ].join(' : ')
    end.join(DiscordClient::MESSAGE_LINE_SEPARATOR)
    client.replace_channel_content teams_list_channel(teams_category_id)['id'], lines
  end

  def rebuild_teams_lu(_teams_category_id = nil)
    teams_category_id = _teams_category_id || teams_category['id']
    lines = Team.order(:name).map do |team|
      [
        "**#{team.short_name} : #{team.name}**",
        players_lines(team.players)
      ].join(DiscordClient::MESSAGE_LINE_SEPARATOR)
    end.join(DiscordClient::MESSAGE_LINE_SEPARATOR * 2)
    client.replace_channel_content teams_lu_channel(teams_category_id)['id'], lines
  end

  # ---------------------------------------------------------------------------
  # PRIVATE
  # ---------------------------------------------------------------------------

  private

  def player_abc(player)
    line = player.name
    player.teams.each do |team|
      line += " [#{team.short_name}]"
    end
    player.locations.each do |location|
      line += " [#{location.name.titleize}]"
    end
    if player.characters.any?
      line += " :"
      player.characters.each do |character|
        line += " <:#{character.name.parameterize.gsub('-','')}:#{character.emoji}>"
      end
    end
    line
  end

  def players_lines(players)
    players.accepted.includes(:teams, :locations, :characters).to_a.sort_by{|p| p.name.downcase}.map do |player|
      player_abc player
    end.join(DiscordClient::MESSAGE_LINE_SEPARATOR)
  end

  def rebuild_channel_with_players(channel_id, players)
    client.replace_channel_content channel_id, players_lines(players)
  end

  def find_or_create_readonly_channel(guild_id, find_params, create_params = {})
    # TODO: handle channel creation errors
    # e.g. {"parent_id"=>["Maximum number of channels in category reached (50)"]}
    client.find_or_create_guild_text_channel guild_id,
                                             find_params,
                                             create_params.merge(readonly: true)
  end

end
