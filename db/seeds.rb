# if needed
# Locations::City.destroy_all
# Character.destroy_all
# Team.destroy_all
# Player.destroy_all

ENV['NO_DISCORD'] = '1'

# Locations::City
unless Locations::City.any?
  uri = "#{ENV['SEED_DATA_SOURCE_URL']}cities.json"
  puts "seed #{uri}"
  open(uri) do |file|
    cities = JSON.parse(file.read)
    cities.each do |city|
      Locations::City.create!(city)
    end
  end
end

# Character
unless Character.any?
  uri = "#{ENV['SEED_DATA_SOURCE_URL']}characters.json"
  puts "seed #{uri}"
  open(uri) do |file|
    characters = JSON.parse(file.read)
    characters.each do |character|
      Character.create!(character)
    end
  end
end

# Team
unless Team.any?
  uri = "#{ENV['SEED_DATA_SOURCE_URL']}teams.json"
  puts "seed #{uri}"
  open(uri) do |file|
    teams = JSON.parse(file.read)
    teams.each do |team|
      Team.create!(team)
    end
  end
end

# Player
unless Player.any?
  uri = "#{ENV['SEED_DATA_SOURCE_URL']}players.json"
  puts "seed #{uri}"
  open(uri) do |file|
    players = JSON.parse(file.read)
    creator = DiscordUser.first
    players.each do |player|
      Player.create!(
        name: player['name'],
        city: player['city'].presence && City.find_by!(name: player['city']),
        team: player['team'].presence && Team.find_by!(short_name: player['team']),
        creator: creator,
        character_ids: player['characters'].map{|c| Character.find_by!(name: c).id}
      )
    end
  end
end

# DiscordGuild
# unless DiscordGuild.any?
  uri = "#{ENV['SEED_DATA_SOURCE_URL']}char_guilds.json"
  puts "seed #{uri}"
  open(uri) do |file|
    guilds = JSON.parse(file.read)
    DiscordGuild.transaction do
      guilds.each do |character_emoji, guild|
        puts "seed guild #{guild.inspect} for character with emoji #{character_emoji}"
        character = Character.by_emoji(character_emoji).first!
        discord_guild = DiscordGuild.create!(
          invitation_url: guild['url']
        )
        guild['admins'].each do |admin|
          player = Player.by_name_like(admin['name']).first!
          discord_user = player.discord_user
          raise "unknown DiscordUser for Player ##{player.id}: #{player.name}"
          DiscordGuildAdmin.create!(
            discord_guild: discord_guild,
            discord_user: discord_user,
            role: admin['role']
          )
        end
      end
    end
  end
# end

ENV['NO_DISCORD'] = '0'
