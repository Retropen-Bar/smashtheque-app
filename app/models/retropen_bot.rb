class RetropenBot
  # ---------------------------------------------------------------------------
  # CONSTANTS
  # ---------------------------------------------------------------------------

  CATEGORY_ACTORS = 'ACTEURS DE LA SCÈNE SMASH'.freeze
  CHANNEL_CASTERS = 'casters'.freeze
  CHANNEL_COACHES = 'coachs'.freeze
  CHANNEL_DISCORD_GUILDS_CHARS = 'commus-fr-par-perso'.freeze
  CHANNEL_GRAPHIC_DESIGNERS = 'graphistes'.freeze
  CHANNEL_TEAM_ADMINS = 'capitaines-d-équipe'.freeze
  CHANNEL_TWITCH_FR = 'twitch-channels-fr'.freeze
  CHANNEL_TWITCH_WORLD = 'twitch-channels-world'.freeze
  CHANNEL_YOUTUBE_FR = 'youtube-channels-fr'.freeze
  CHANNEL_YOUTUBE_WORLD = 'youtube-channels-world'.freeze

  EMOJI_GUILD_ADMIN = '746006429156245536'.freeze
  EMOJI_TEAM_ADMIN = '745255339364057119'.freeze
  EMOJI_TWITCH = '862611411024085012'.freeze
  EMOJI_YOUTUBE = '743601431499767899'.freeze
  EMOJI_POINTS_ONLINE = '795277209715212298'.freeze
  EMOJI_POINTS_OFFLINE = '847205931958927371'.freeze
  EMOJI_GRAPHIC_DESIGNER = '752212651421204560'.freeze
  EMOJI_GRAPHIC_DESIGNER_AVAILABLE = '752212329327755304'.freeze
  EMOJI_GRAPHIC_DESIGNER_UNAVAILABLE = '752212328833089746'.freeze
  EMOJI_CASTER = '745255394632269984'.freeze
  EMOJI_COACH = '743286485930868827'.freeze

  ONLINE_TO_ROLE_ID = ENV['DISCORD_ONLINE_TO_ROLE_ID']
  OFFLINE_TO_ROLE_ID = ENV['DISCORD_OFFLINE_TO_ROLE_ID']

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
  # ACTORS
  # ---------------------------------------------------------------------------

  def actors_category
    client.find_or_create_guild_category @guild_id, name: CATEGORY_ACTORS
  end

  def discord_guilds_chars_list_channel(actors_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_DISCORD_GUILDS_CHARS,
                                    parent_id: actors_category_id || actors_category['id']
  end

  def casters_list_channel(actors_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_CASTERS,
                                    parent_id: actors_category_id || actors_category['id']
  end

  def coaches_list_channel(actors_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_COACHES,
                                    parent_id: actors_category_id || actors_category['id']
  end

  def graphic_designers_list_channel(actors_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_GRAPHIC_DESIGNERS,
                                    parent_id: actors_category_id || actors_category['id']
  end

  def team_admins_list_channel(actors_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_TEAM_ADMINS,
                                    parent_id: actors_category_id || actors_category['id']
  end

  def twitch_fr_list_channel(actors_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_TWITCH_FR,
                                    parent_id: actors_category_id || actors_category['id']
  end

  def twitch_world_list_channel(actors_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_TWITCH_WORLD,
                                    parent_id: actors_category_id || actors_category['id']
  end

  def youtube_fr_list_channel(actors_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_YOUTUBE_FR,
                                    parent_id: actors_category_id || actors_category['id']
  end

  def youtube_world_list_channel(actors_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_YOUTUBE_WORLD,
                                    parent_id: actors_category_id || actors_category['id']
  end

  def rebuild_discord_guilds_chars_list(_actors_category_id = nil)
    actors_category_id = _actors_category_id || actors_category['id']

    characters = Character.with_discord_guild
                          .sort_by do |character|
                            character.name.downcase
                          end

    messages = characters.map do |character|
      discord_guild = character.discord_guilds.first
      message = DiscordClient::EMPTY_LINE + DiscordClient::MESSAGE_LINE_SEPARATOR
      message += "**#{character.name.upcase}** " + character_emoji_tag(character)
      message += discord_guild.discord_guild_admins.map do |discord_guild_admin|
        discord_user = discord_guild_admin.discord_user
        line = DiscordClient::MESSAGE_LINE_SEPARATOR + "\t\t"
        line += emoji_tag(EMOJI_GUILD_ADMIN)
        line += " #{discord_user.player&.name || discord_user.username}"
        line += " [#{discord_guild_admin.role}]" unless discord_guild_admin.role.blank?
        line
      end.join
      message += DiscordClient::MESSAGE_LINE_SEPARATOR + "\t\t"
      message += "🔗 " + discord_guild.invitation_url
      message += DiscordClient::MESSAGE_LINE_SEPARATOR + DiscordClient::EMPTY_LINE
      message
    end

    client.replace_channel_messages(
      discord_guilds_chars_list_channel(actors_category_id)['id'],
      messages
    )
  end

  def rebuild_casters_list(_actors_category_id = nil)
    actors_category_id = _actors_category_id || actors_category['id']

    users = {}
    User.casters.order("LOWER(name)").all.each do |user|
      letter = self.class.name_letter user.name
      users[letter] ||= []
      users[letter] << emoji_tag(EMOJI_CASTER) + ' **' + user.name + '**'
      users[letter] << DiscordClient::EMPTY_LINE
    end

    lines = []
    (('a'..'z').to_a + ['$']).each do |letter|
      lines << letter_emoji_tag(letter)
      lines << DiscordClient::EMPTY_LINE
      lines += users[letter] || []
      lines << DiscordClient::EMPTY_LINE
    end
    lines = lines.join(DiscordClient::MESSAGE_LINE_SEPARATOR)
    client.replace_channel_content casters_list_channel(actors_category_id)['id'], lines
  end

  def rebuild_coaches_list(_actors_category_id = nil)
    actors_category_id = _actors_category_id || actors_category['id']

    messages = User.coaches.order("LOWER(name)").all.map do |user|
      message = DiscordClient::EMPTY_LINE + DiscordClient::MESSAGE_LINE_SEPARATOR
      message += emoji_tag(EMOJI_COACH)
      message += ' **' + user.name + '**'
      unless user.coaching_details.blank?
        message += DiscordClient::MESSAGE_LINE_SEPARATOR + "\t\t" + user.coaching_details
      end
      unless user.coaching_url.blank?
        message += DiscordClient::MESSAGE_LINE_SEPARATOR + "\t\t" + user.coaching_url
      end
      message += DiscordClient::MESSAGE_LINE_SEPARATOR + DiscordClient::EMPTY_LINE
      message
    end

    client.replace_channel_messages coaches_list_channel(actors_category_id)['id'], messages
  end

  def rebuild_graphic_designers_list(_actors_category_id = nil)
    actors_category_id = _actors_category_id || actors_category['id']

    users = {}
    User.graphic_designers.order("LOWER(name)").all.each do |user|
      letter = self.class.name_letter user.name
      users[letter] ||= []
      users[letter] << (
        line = emoji_tag(EMOJI_GRAPHIC_DESIGNER)
        line += ' **' + user.name + '**'
        line += ' ['
        if user.is_available_graphic_designer?
          line += emoji_tag(EMOJI_GRAPHIC_DESIGNER_AVAILABLE)
        else
          line += emoji_tag(EMOJI_GRAPHIC_DESIGNER_UNAVAILABLE)
        end
        line += ']'
        unless user.graphic_designer_details.blank?
          line += DiscordClient::MESSAGE_LINE_SEPARATOR + user.graphic_designer_details
        end
        line
      )
      users[letter] << DiscordClient::EMPTY_LINE
    end

    lines = []
    (('a'..'z').to_a + ['$']).each do |letter|
      lines << letter_emoji_tag(letter)
      lines << DiscordClient::EMPTY_LINE
      lines += users[letter] || []
      lines << DiscordClient::EMPTY_LINE
    end
    lines = lines.join(DiscordClient::MESSAGE_LINE_SEPARATOR)
    client.replace_channel_content graphic_designers_list_channel(actors_category_id)['id'], lines
  end

  def rebuild_team_admins_list(_actors_category_id = nil)
    actors_category_id = _actors_category_id || actors_category['id']

    admins = {}
    latest_user_id = 0
    TeamAdmin.order(:user_id).all.each do |team_admin|
      # we might have already seen this person
      next if team_admin.user_id == latest_user_id
      latest_user_id = team_admin.user_id

      user = team_admin.user
      name = user.player&.name || user.name
      letter = self.class.name_letter name
      admins[letter] ||= []
      admins[letter] << (
        [
          emoji_tag(EMOJI_TEAM_ADMIN),
          name
        ] + user.administrated_teams.order(:short_name).map do |team|
          "[#{team.short_name}]"
        end
      ).join(' ')
      admins[letter] << DiscordClient::EMPTY_LINE
    end

    lines = []
    (('a'..'z').to_a + ['$']).each do |letter|
      lines << letter_emoji_tag(letter)
      lines << DiscordClient::EMPTY_LINE
      lines += admins[letter] || []
      lines << DiscordClient::EMPTY_LINE
    end
    lines = lines.join(DiscordClient::MESSAGE_LINE_SEPARATOR)
    client.replace_channel_content team_admins_list_channel(actors_category_id)['id'], lines
  end

  def rebuild_twitch_fr_list(_actors_category_id = nil)
    actors_category_id = _actors_category_id || actors_category['id']
    named_lines = video_channels TwitchChannel.french, EMOJI_TWITCH
    rebuild_channel_with_named_lines twitch_fr_list_channel(actors_category_id)['id'], named_lines
  end

  def rebuild_twitch_world_list(_actors_category_id = nil)
    actors_category_id = _actors_category_id || actors_category['id']
    named_lines = video_channels TwitchChannel.not_french, EMOJI_TWITCH
    rebuild_channel_with_named_lines twitch_world_list_channel(actors_category_id)['id'], named_lines
  end

  def rebuild_youtube_fr_list(_actors_category_id = nil)
    actors_category_id = _actors_category_id || actors_category['id']
    named_lines = video_channels YouTubeChannel.french, EMOJI_YOUTUBE
    rebuild_channel_with_named_lines youtube_fr_list_channel(actors_category_id)['id'], named_lines
  end

  def rebuild_youtube_world_list(_actors_category_id = nil)
    actors_category_id = _actors_category_id || actors_category['id']
    named_lines = video_channels YouTubeChannel.not_french, EMOJI_YOUTUBE
    rebuild_channel_with_named_lines youtube_world_list_channel(actors_category_id)['id'], named_lines
  end

  # ---------------------------------------------------------------------------
  # ROLES
  # ---------------------------------------------------------------------------

  def toggle_role(discord_id, role_id, toggle)
    return false unless role_id

    client.toggle_user_role(
      toggle,
      guild_id: @guild_id,
      user_id: discord_id,
      role_id: role_id
    )
  end

  def update_member_roles(discord_id)
    discord_user = DiscordUser.find_by(discord_id: discord_id)
    return false unless discord_user&.user

    toggle_role(
      discord_id,
      ONLINE_TO_ROLE_ID,
      discord_user.administrated_recurring_tournaments.online.any?
    )
    toggle_role(
      discord_id,
      OFFLINE_TO_ROLE_ID,
      discord_user.administrated_recurring_tournaments.offline.any?
    )
  end

  # ---------------------------------------------------------------------------
  # MISC
  # ---------------------------------------------------------------------------

  def self.name_letter(name)
    return nil if name.blank?
    I18n.transliterate(name.first).downcase
  end

  # ---------------------------------------------------------------------------
  # PRIVATE
  # ---------------------------------------------------------------------------

  private

  def emoji_tag(emoji_id)
    "<:placeholder:#{emoji_id}>"
  end

  def character_emoji_tag(character)
    "<:#{character.name.parameterize.gsub('-','')}:#{character.emoji}>"
  end

  def letter_emoji_tag(letter)
    return '🟦' if letter == '$'
    [
      127462 + (letter.downcase.ord - "a".ord)
    ].pack('U')
  end

  def escape_message_content(content)
    content.gsub('_','\_').gsub('*','\*')
  end

  def video_channel_line(model, emoji_id)
    line = [
      emoji_tag(emoji_id),
      '**' + escape_message_content(model.name) + '**'
    ].join(' ')
    details = []
    unless model.related.nil?
      details << if model.related.is_a?(Character)
        character_emoji_tag(model.related)
      else
        model.related.decorate.listing_name
      end
    end
    unless model.description.blank?
      details << model.description
    end
    if details.any?
      line += DiscordClient::MESSAGE_LINE_SEPARATOR + "\t\t" + escape_message_content(details.join(', '))
    end
    line += DiscordClient::MESSAGE_LINE_SEPARATOR + "\t\t" + model.decorate.channel_url
    line
  end

  def video_channels(models, emoji_id)
    result = {}
    models.order("LOWER(name)").all.each_with_index do |model, idx|
      line = [
        DiscordClient::EMPTY_LINE,
        video_channel_line(model, emoji_id),
        DiscordClient::EMPTY_LINE
      ].join(DiscordClient::MESSAGE_LINE_SEPARATOR)
      letter = self.class.name_letter model.name
      result[letter] ||= []
      result[letter] << line
    end
    result
  end

  def rebuild_channel_with_named_lines(channel_id, named_lines)
    messages = []
    ('a'..'z').each do |letter|
      # messages << letter.upcase
      messages += named_lines[letter] || []
    end
    client.replace_channel_messages channel_id, messages
  end

  def find_or_create_readonly_channel(guild_id, find_params, create_params = {})
    # TODO: handle channel creation errors
    # e.g. {"parent_id"=>["Maximum number of channels in category reached (50)"]}
    client.find_or_create_guild_text_channel guild_id,
                                             find_params,
                                             create_params.merge(readonly: true)
  end
end
