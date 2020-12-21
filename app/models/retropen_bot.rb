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
  CHANNEL_TEAMS_LU1 = 'roster-équipes-a-i'.freeze
  CHANNEL_TEAMS_LU2 = 'roster-équipes-j-r'.freeze
  CHANNEL_TEAMS_LU3 = 'roster-équipes-s-z-autres'.freeze
  CATEGORY_ACTORS = 'ACTEURS DE LA SCÈNE SMASH'.freeze
  CHANNEL_DISCORD_GUILDS_CHARS = 'commus-fr-par-perso'.freeze
  CHANNEL_TEAM_ADMINS = 'capitaines-d-équipe'.freeze
  CHANNEL_TWITCH_FR = 'twitch-channels-fr'.freeze
  CHANNEL_TWITCH_WORLD = 'twitch-channels-world'.freeze
  CHANNEL_YOUTUBE_FR = 'youtube-channels-fr'.freeze
  CHANNEL_YOUTUBE_WORLD = 'youtube-channels-world'.freeze
  CATEGORY_ONLINE_TOURNAMENTS = 'TOURNOIS ONLINE'.freeze
  CHANNEL_ONLINE_TOURNAMENTS_IRREGULAR = 'irrégulier'.freeze
  CHANNEL_ONLINE_TOURNAMENTS_ONESHOT = 'one-shot'.freeze
  CHANNEL_ONLINE_TOURNAMENTS_DAYS = %w(
    dimanche
    lundi
    mardi
    mercredi
    jeudi
    vendredi
    samedi
  ).freeze
  EMOJI_GUILD_ADMIN = '746006429156245536'.freeze
  EMOJI_TEAM_ADMIN = '745255339364057119'.freeze
  EMOJI_TWITCH = '743601202716999720'.freeze
  EMOJI_YOUTUBE = '743601431499767899'.freeze
  EMOJI_TOURNAMENT = '743286485930868827'.freeze
  EMOJI_NO_REWARD = '790617900012535838'.freeze

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
    channel_name = character.name.parameterize
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
    channel_name = location.name.parameterize
    channel = find_or_create_readonly_channel @guild_id,
                                              name: channel_name,
                                              parent_id: parent_category_id
    rebuild_channel_with_players channel['id'],
                                 location.players
  end

  # ---------------------------------------------------------------------------
  # TEAMS
  # ---------------------------------------------------------------------------

  # LU 1 : a..i
  # LU 2 : j..r
  # LU 3 : s..z + autres

  def teams_category
    client.find_or_create_guild_category @guild_id, name: CATEGORY_TEAMS
  end

  def teams_list_channel(teams_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_TEAMS_LIST,
                                    parent_id: teams_category_id || teams_category['id']
  end

  def teams_lu_channel1(teams_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_TEAMS_LU1,
                                    parent_id: teams_category_id || teams_category['id']
  end

  def teams_lu_channel2(teams_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_TEAMS_LU2,
                                    parent_id: teams_category_id || teams_category['id']
  end

  def teams_lu_channel3(teams_category_id = nil)
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_TEAMS_LU3,
                                    parent_id: teams_category_id || teams_category['id']
  end

  def rebuild_teams_list(_teams_category_id = nil)
    teams_category_id = _teams_category_id || teams_category['id']
    lines = Team.order(:name).map do |team|
      team_line(team)
    end.join(DiscordClient::MESSAGE_LINE_SEPARATOR)
    client.replace_channel_content teams_list_channel(teams_category_id)['id'], lines
  end

  def rebuild_teams_lu(_teams_category_id = nil)
    # build lines
    lines1 = []
    lines2 = []
    lines3 = []
    Team.order(:name).each do |team|
      admins = team.team_admins.map(&:discord_user_id)
      lines = ["**#{team.short_name} : #{team.name}**"]
      lines += team.players
          .legit
          .includes(:teams, :locations, :characters)
          .to_a
          .sort_by { |p| p.name.downcase }
          .map do |player|
        line = player_abc player
        if admins.include?(player.discord_user_id)
          line += ' (capitaine)'
        end
        line
      end
      lines = lines.join(DiscordClient::MESSAGE_LINE_SEPARATOR)
      letter = self.class.name_letter team.name
      if ('a'..'i').include?(letter)
        lines1 << lines
      elsif ('j'..'r').include?(letter)
        lines2 << lines
      else
        lines3 << lines
      end
    end
    lines1 = lines1.join(DiscordClient::MESSAGE_LINE_SEPARATOR * 2)
    lines2 = lines2.join(DiscordClient::MESSAGE_LINE_SEPARATOR * 2)
    lines3 = lines3.join(DiscordClient::MESSAGE_LINE_SEPARATOR * 2)

    # rebuild channels
    teams_category_id = _teams_category_id || teams_category['id']
    client.replace_channel_content teams_lu_channel1(teams_category_id)['id'], lines1
    client.replace_channel_content teams_lu_channel2(teams_category_id)['id'], lines2
    client.replace_channel_content teams_lu_channel3(teams_category_id)['id'], lines3
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
      [
        "**#{character.name.upcase}**",
        character_emoji_tag(character),
        discord_guild.invitation_url,
        emoji_tag(EMOJI_GUILD_ADMIN),
        discord_guild.discord_guild_admins.map do |discord_guild_admin|
          discord_user = discord_guild_admin.discord_user
          result = discord_user.player&.name || discord_user.username
          result += " [#{discord_guild_admin.role}]" unless discord_guild_admin.role.blank?
          result
        end.join(', ')
      ].join(' ')
    end
    client.replace_channel_messages(
      discord_guilds_chars_list_channel(actors_category_id)['id'],
      messages
    )
  end

  def rebuild_team_admins_list(_actors_category_id = nil)
    actors_category_id = _actors_category_id || actors_category['id']

    admins = {}
    latest_discord_user_id = 0
    TeamAdmin.order(:discord_user_id).all.each do |team_admin|
      # we might have already seen this person
      next if team_admin.discord_user_id == latest_discord_user_id
      latest_discord_user_id = team_admin.discord_user_id

      discord_user = team_admin.discord_user
      name = discord_user.player&.name || discord_user.username
      letter = self.class.name_letter name
      admins[letter] ||= []
      admins[letter] << (
        [
          emoji_tag(EMOJI_TEAM_ADMIN),
          name
        ] + discord_user.administrated_teams.order(:short_name).map do |team|
          "[#{team.short_name}]"
        end
      ).join(' ')
    end

    lines = []
    (('a'..'z').to_a + ['$']).each do |letter|
      lines << letter.upcase
      lines += admins[letter] || []
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
  # TOURNAMENTS
  # ---------------------------------------------------------------------------

  def online_tournaments_category
    client.find_or_create_guild_category @guild_id, name: CATEGORY_ONLINE_TOURNAMENTS
  end

  def online_tournaments_irregular_channel(_online_tournaments_category_id = nil)
    online_tournaments_category_id = _online_tournaments_category_id || online_tournaments_category['id']
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_ONLINE_TOURNAMENTS_IRREGULAR,
                                    parent_id: online_tournaments_category_id
  end

  def online_tournaments_oneshot_channel(_online_tournaments_category_id = nil)
    online_tournaments_category_id = _online_tournaments_category_id || online_tournaments_category['id']
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_ONLINE_TOURNAMENTS_ONESHOT,
                                    parent_id: online_tournaments_category_id
  end

  def online_tournaments_wday_channel(wday, _online_tournaments_category_id = nil)
    online_tournaments_category_id = _online_tournaments_category_id || online_tournaments_category['id']
    find_or_create_readonly_channel @guild_id,
                                    name: CHANNEL_ONLINE_TOURNAMENTS_DAYS[wday],
                                    parent_id: online_tournaments_category_id
  end

  def rebuild_online_tournaments_channel(recurring_tournaments, channel_id)
    messages = []
    recurring_tournaments.online
                         .not_archived
                         .order(:starts_at)
                         .decorate
                         .each do |recurring_tournament|
      messages << emoji_tag(EMOJI_TOURNAMENT) * 3
      messages << [
        "Tournoi : #{recurring_tournament.name}",
        "Fréquence : #{recurring_tournament.recurring_type_text}",
        "Date : #{recurring_tournament.full_date}",
        "Serveur : #{recurring_tournament.discord_guild_invitation_url}",
        "Difficulté : #{recurring_tournament.level_text}",
        "Disponibilité : Ouvert à tous",
        "Taille : #{RecurringTournamentDecorator.size_name(recurring_tournament.size)}",
        "Comment s'inscrire : #{recurring_tournament.registration.gsub(/\R+/, '; ')}",
        "Contact : " + recurring_tournament.contacts.map do |discord_user|
          discord_user.player&.name || discord_user.username
        end.join(', ')
      ].join("\n")
    end
    client.replace_channel_messages(
      channel_id,
      messages
    )
  end

  def rebuild_online_tournaments_wday(wday, _online_tournaments_category_id = nil)
    rebuild_online_tournaments_channel(
      RecurringTournament.recurring.on_wday(wday),
      online_tournaments_wday_channel(wday, _online_tournaments_category_id)['id']
    )
  end

  def rebuild_online_tournaments_irregular(_online_tournaments_category_id = nil)
    rebuild_online_tournaments_channel(
      RecurringTournament.irregular,
      online_tournaments_irregular_channel(_online_tournaments_category_id)['id']
    )
  end

  def rebuild_online_tournaments_oneshot(_online_tournaments_category_id = nil)
    rebuild_online_tournaments_channel(
      RecurringTournament.oneshot,
      online_tournaments_oneshot_channel(_online_tournaments_category_id)['id']
    )
  end

  def rebuild_online_tournaments(_online_tournaments_category_id = nil)
    online_tournaments_category_id = _online_tournaments_category_id || online_tournaments_category['id']

    (0..6).each do |wday|
      rebuild_online_tournaments_wday wday, online_tournaments_category_id
    end
    rebuild_online_tournaments_irregular online_tournaments_category_id
    rebuild_online_tournaments_oneshot online_tournaments_category_id
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

  def escape_message_content(content)
    content.gsub('_','\_').gsub('*','\*')
  end

  def player_abc(player)
    line = emoji_tag(
      if player.best_reward
        player.best_reward.emoji
      else
        EMOJI_NO_REWARD
      end
    )
    line += " #{player.name}"
    player.teams.each do |team|
      line += " [#{team.short_name}]"
    end
    player.locations.each do |location|
      line += " [#{location.name.titleize}]"
    end
    if player.characters.any?
      line += " :"
      player.characters.each do |character|
        line += " #{character_emoji_tag(character)}"
      end
    end
    escape_message_content line
  end

  def players_lines(players)
    players.legit.includes(:teams, :locations, :characters).to_a.sort_by do |player|
      I18n.transliterate(player.name).downcase
    end.map do |player|
      player_abc player
    end.join(DiscordClient::MESSAGE_LINE_SEPARATOR)
  end

  def team_line(team)
    line = [
      team.short_name,
      team.name
    ].join(' : ')
    if team.admins.any?
      line += ' ' + emoji_tag(EMOJI_TEAM_ADMIN) + ' '
      line += team.admins.map do |discord_user|
        discord_user.player&.name || discord_user.username
      end.join(', ')
    end
    escape_message_content line
  end

  def video_channel_line(model, emoji_id)
    name = model.username

    line = [
      emoji_tag(emoji_id),
      name
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
      line += ' -> ' + details.join(', ')
    end

    escape_message_content line
  end

  def video_channels(models, emoji_id)
    result = {}
    models.order(:username).all.each do |model|
      line = video_channel_line model, emoji_id
      letter = self.class.name_letter model.username
      result[letter] ||= []
      result[letter] << line
    end
    result
  end

  def rebuild_channel_with_named_lines(channel_id, named_lines)
    lines = []
    (('a'..'z').to_a + ['$']).each do |letter|
      lines << letter.upcase
      lines += named_lines[letter] || []
    end
    lines = lines.join(DiscordClient::MESSAGE_LINE_SEPARATOR)
    client.replace_channel_content channel_id, lines
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
