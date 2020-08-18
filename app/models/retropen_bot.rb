class RetropenBot

  # constants

  CATEGORY_ABC = 'ABÉCÉDAIRE DES JOUEURS FR'.freeze
  CHANNEL_ABC_OTHERS = 'symboles-0-9'.freeze

  # constructor

  def initialize(guild_id: nil)
    @guild_id = guild_id || ENV['DISCORD_GUILD_ID']
  end

  # methods

  def find_abc_category
    client.find_or_create_guild_category @guild_id, name: CATEGORY_ABC
  end

  def fill_abc_channel(channel_id, players)
    lines = players.to_a.sort_by{|p| p.name.downcase}.map do |player|
      player_abc player
    end.join(DiscordClient::MESSAGE_LINE_SEPARATOR)

    client.create_channel_message channel_id, lines
  end

  def rebuild_abc_channel(channel_id, players)
    client.clear_channel channel_id
    fill_abc_channel channel_id, players
  end

  def rebuild_abc
    abc_category = find_abc_category

    ('a'..'b').each do |letter|
      abc_channel = client.find_or_create_guild_text_channel @guild_id,
                                                             name: letter,
                                                             parent_id: abc_category['id']
      rebuild_abc_channel abc_channel['id'], Player.on_abc(letter)
    end

    abc_others_channel = client.find_or_create_guild_text_channel @guild_id,
                                                                  name: CHANNEL_ABC_OTHERS,
                                                                  parent_id: abc_category['id']
    rebuild_abc_channel abc_others_channel['id'], Player.on_abc_others
  end

  private

  def client
    @client ||= DiscordClient.new
  end

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

end
