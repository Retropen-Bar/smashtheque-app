class RetropenBot

  # ---------------------------------------------------------------------------
  # CONSTANTS
  # ---------------------------------------------------------------------------

  CATEGORY_ABC = 'ABÉCÉDAIRE DES JOUEURS FR'.freeze
  CHANNEL_ABC_OTHERS = 'symboles-0-9'.freeze
  CATEGORY_CHARS1 = 'ROSTER DE A À M'.freeze
  CATEGORY_CHARS2 = 'ROSTER DE N À Z'.freeze
  CATEGORY_CITIES = 'JOUEURS PAR VILLE'.freeze
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

  def name_letter(name)
    return nil if name.blank?
    I18n.transliterate(name.first).downcase
  end

  def abc_category
    @abc_category ||= client.find_or_create_guild_category @guild_id, name: CATEGORY_ABC
  end

  def rebuild_abc_letter(letter)
    abc_channel = client.find_or_create_guild_text_channel @guild_id,
                                                           name: letter,
                                                           parent_id: abc_category['id']
    rebuild_channel_with_players abc_channel['id'],
                                 Player.on_abc(letter)
  end

  def rebuild_abc_others
    abc_others_channel = client.find_or_create_guild_text_channel @guild_id,
                                                                  name: CHANNEL_ABC_OTHERS,
                                                                  parent_id: abc_category['id']
    rebuild_channel_with_players abc_others_channel['id'],
                                 Player.on_abc_others
  end

  def rebuild_abc_for_name(name)
    return false if name.blank?
    rebuild_abc_for_letter name_letter(name)
  end

  def rebuild_abc_for_letter(letter)
    if ('a'..'z').include?(letter)
      rebuild_abc_letter letter
    else
      rebuild_abc_others
    end
  end

  def rebuild_abc_for_letters(letters)
    need_rebuild_abc_others = false
    letters.compact.uniq.each do |letter|
      if ('a'..'z').include?(letter)
        rebuild_abc_letter letter
      else
        need_rebuild_abc_others = true
      end
    end
    rebuild_abc_others if need_rebuild_abc_others
  end

  def rebuild_abc_for_players(players)
    letters = players.map do |player|
      name_letter player&.name
    end
    rebuild_abc_for_letters letters
  end

  def rebuild_abc
    ('a'..'z').each do |letter|
      rebuild_abc_letter letter
    end
    rebuild_abc_others
  end

  # ---------------------------------------------------------------------------
  # CHARS
  # ---------------------------------------------------------------------------

  def chars_category1
    @chars_category1 ||= client.find_or_create_guild_category @guild_id, name: CATEGORY_CHARS1
  end

  def chars_category2
    @chars_category2 ||= client.find_or_create_guild_category @guild_id, name: CATEGORY_CHARS2
  end

  def rebuild_chars_for_character(character)
    return false if character.nil?
    letter = name_letter character.name
    parent_category = if ('a'..'m').include?(letter)
      chars_category1
    else
      chars_category2
    end
    channel_name = [character.icon, character.name].join
    channel = client.find_or_create_guild_text_channel @guild_id,
                                                       name: channel_name,
                                                       parent_id: parent_category['id']
    rebuild_channel_with_players channel['id'],
                                 character.players
  end

  def rebuild_chars_for_characters(characters)
    characters.compact.uniq.each do |character|
      rebuild_chars_for_character character
    end
  end

  def rebuild_chars
    rebuild_chars_for_characters Character.all
  end

  # ---------------------------------------------------------------------------
  # CITIES
  # ---------------------------------------------------------------------------

  def cities_category
    @cities_category ||= client.find_or_create_guild_category @guild_id, name: CATEGORY_CITIES
  end

  def rebuild_cities_for_city(city)
    return false if city.nil?
    channel_name = [city.icon, city.name].join
    channel = client.find_or_create_guild_text_channel @guild_id,
                                                       name: channel_name,
                                                       parent_id: cities_category['id']
    rebuild_channel_with_players channel['id'],
                                 city.players
  end

  def rebuild_cities_for_cities(cities)
    cities.to_a.compact.uniq.each do |city|
      rebuild_cities_for_city city
    end
  end

  def rebuild_cities
    rebuild_cities_for_cities City.order(:name)
  end

  # ---------------------------------------------------------------------------
  # TEAMS
  # ---------------------------------------------------------------------------

  def teams_category
    @teams_category ||= client.find_or_create_guild_category @guild_id, name: CATEGORY_TEAMS
  end

  def teams_list_channel
    @teams_list_channel ||= (
      client.find_or_create_guild_text_channel @guild_id,
                                               name: CHANNEL_TEAMS_LIST,
                                               parent_id: teams_category['id']
    )
  end

  def teams_lu_channel
    @teams_lu_channel ||= (
      client.find_or_create_guild_text_channel @guild_id,
                                               name: CHANNEL_TEAMS_LU,
                                               parent_id: teams_category['id']
    )
  end

  def rebuild_teams_list
    lines = Team.order(:name).map do |team|
      [
        team.short_name,
        team.name
      ].join(' : ')
    end.join(DiscordClient::MESSAGE_LINE_SEPARATOR)
    rebuild_channel_with_content teams_list_channel['id'], lines
  end

  def rebuild_teams_lu
    lines = Team.order(:name).map do |team|
      [
        "**#{team.short_name} : #{team.name}**",
        players_lines(team.players)
      ].join(DiscordClient::MESSAGE_LINE_SEPARATOR)
    end.join(DiscordClient::MESSAGE_LINE_SEPARATOR * 2)
    rebuild_channel_with_content teams_lu_channel['id'], lines
  end

  def rebuild_teams
    rebuild_teams_list
    rebuild_teams_lu
  end

  # ---------------------------------------------------------------------------
  # PRIVATE
  # ---------------------------------------------------------------------------

  private

  def character_visual(character)
    return character.icon if character.emoji.blank?

    found_emoji_id = client.find_guild_emoji_id @guild_id, character.emoji
    return character.icon if found_emoji_id.nil?

    "<:#{character.emoji}:#{found_emoji_id}>"
  end

  def player_abc(player)
    line = player.name
    if player.team
      line += " [#{player.team.short_name}]"
    end
    if player.city
      line += " [#{player.city.name}]"
    end
    if player.characters.any?
      line += " :"
      player.characters.each do |character|
        line += " #{character_visual(character)}"
      end
    end
    line
  end

  def players_lines(players)
    players.includes(:team, :city, :characters).to_a.sort_by{|p| p.name.downcase}.map do |player|
      player_abc player
    end.join(DiscordClient::MESSAGE_LINE_SEPARATOR)
  end

  def rebuild_channel_with_players(channel_id, players)
    client.replace_channel_content channel_id, players_lines(players)
  end

end
