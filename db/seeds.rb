# if needed
# Character.destroy_all
# Team.destroy_all
# Player.destroy_all

DiscordUser.delete_all
discord_user = DiscordUser.new(discord_id: '608210202952466464')
discord_user.save!
User.create!(
  discord_user: discord_user,
  admin_level: Ability::ADMIN_LEVEL_ADMIN,
  is_root: true
)

ENV['NO_DISCORD'] = '1'

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
unless DiscordGuild.any?
  uri = "#{ENV['SEED_DATA_SOURCE_URL']}char_guilds.json"
  puts "seed #{uri}"
  open(uri) do |file|
    guilds = JSON.parse(file.read)
    DiscordGuild.transaction do
      guilds.each do |character_emoji, guild|
        puts "seed guild #{guild.inspect} for character with emoji #{character_emoji}"
        character = Character.by_emoji(character_emoji).first!
        discord_guild = DiscordGuild.create!(
          related: character,
          invitation_url: guild['url']
        )
        guild['admins'].each do |admin|
          player = Player.by_name_like(admin['name']).order(:discord_user_id).first!
          discord_user = player.discord_user
          raise "unknown DiscordUser for Player ##{player.id}: #{player.name}" if discord_user.nil?
          DiscordGuildAdmin.create!(
            discord_guild: discord_guild,
            discord_user: discord_user,
            role: admin['role']
          )
        end
      end
    end
  end
end

client = DiscordClient.new
emojis = client.get_guild_emojis('790562015776866305')

Reward.transaction do
  (1..6).each do |lvl1|
    (1..6).each do |lvl2|
      emoji_name = "lvl#{lvl1}#{lvl2}"
      emoji = emojis.find { |emoji| emoji['name'] == emoji_name }
      raise "Emoji #{emoji_name} not found" if emoji.nil?
      reward = Reward.create!(
        level1: lvl1,
        level2: lvl2,
        name: "Niveau #{lvl1}.#{lvl2}",
        emoji: emoji['id']
      )
    end
  end
end

RewardCondition.create!(rank: 7, size_min: 9, size_max: 16, points: 6, reward: Reward.by_level(1, 1).first)
RewardCondition.create!(rank: 5, size_min: 9, size_max: 16, points: 8, reward: Reward.by_level(1, 2).first)
RewardCondition.create!(rank: 4, size_min: 9, size_max: 16, points: 12, reward: Reward.by_level(1, 3).first)
RewardCondition.create!(rank: 3, size_min: 9, size_max: 16, points: 16, reward: Reward.by_level(1, 4).first)
RewardCondition.create!(rank: 2, size_min: 9, size_max: 16, points: 24, reward: Reward.by_level(1, 5).first)
RewardCondition.create!(rank: 1, size_min: 9, size_max: 16, points: 48, reward: Reward.by_level(1, 6).first)
RewardCondition.create!(rank: 7, size_min: 17, size_max: 24, points: 9, reward: Reward.by_level(2, 1).first)
RewardCondition.create!(rank: 5, size_min: 17, size_max: 24, points: 12, reward: Reward.by_level(2, 2).first)
RewardCondition.create!(rank: 4, size_min: 17, size_max: 24, points: 18, reward: Reward.by_level(2, 3).first)
RewardCondition.create!(rank: 3, size_min: 17, size_max: 24, points: 24, reward: Reward.by_level(2, 4).first)
RewardCondition.create!(rank: 2, size_min: 17, size_max: 24, points: 36, reward: Reward.by_level(2, 5).first)
RewardCondition.create!(rank: 1, size_min: 17, size_max: 24, points: 72, reward: Reward.by_level(2, 6).first)
RewardCondition.create!(rank: 7, size_min: 25, size_max: 32, points: 12, reward: Reward.by_level(3, 1).first)
RewardCondition.create!(rank: 5, size_min: 25, size_max: 32, points: 16, reward: Reward.by_level(3, 2).first)
RewardCondition.create!(rank: 4, size_min: 25, size_max: 32, points: 24, reward: Reward.by_level(3, 3).first)
RewardCondition.create!(rank: 3, size_min: 25, size_max: 32, points: 32, reward: Reward.by_level(3, 4).first)
RewardCondition.create!(rank: 2, size_min: 25, size_max: 32, points: 48, reward: Reward.by_level(3, 5).first)
RewardCondition.create!(rank: 1, size_min: 25, size_max: 32, points: 96, reward: Reward.by_level(3, 6).first)
RewardCondition.create!(rank: 7, size_min: 33, size_max: 64, points: 24, reward: Reward.by_level(4, 1).first)
RewardCondition.create!(rank: 5, size_min: 33, size_max: 64, points: 32, reward: Reward.by_level(4, 2).first)
RewardCondition.create!(rank: 4, size_min: 33, size_max: 64, points: 48, reward: Reward.by_level(4, 3).first)
RewardCondition.create!(rank: 3, size_min: 33, size_max: 64, points: 64, reward: Reward.by_level(4, 4).first)
RewardCondition.create!(rank: 2, size_min: 33, size_max: 64, points: 96, reward: Reward.by_level(4, 5).first)
RewardCondition.create!(rank: 1, size_min: 33, size_max: 64, points: 192, reward: Reward.by_level(4, 6).first)
RewardCondition.create!(rank: 7, size_min: 65, size_max: 128, points: 48, reward: Reward.by_level(5, 1).first)
RewardCondition.create!(rank: 5, size_min: 65, size_max: 128, points: 64, reward: Reward.by_level(5, 2).first)
RewardCondition.create!(rank: 4, size_min: 65, size_max: 128, points: 96, reward: Reward.by_level(5, 3).first)
RewardCondition.create!(rank: 3, size_min: 65, size_max: 128, points: 128, reward: Reward.by_level(5, 4).first)
RewardCondition.create!(rank: 2, size_min: 65, size_max: 128, points: 192, reward: Reward.by_level(5, 5).first)
RewardCondition.create!(rank: 1, size_min: 65, size_max: 128, points: 384, reward: Reward.by_level(5, 6).first)
RewardCondition.create!(rank: 7, size_min: 129, size_max: 1024, points: 144, reward: Reward.by_level(6, 1).first)
RewardCondition.create!(rank: 5, size_min: 129, size_max: 1024, points: 192, reward: Reward.by_level(6, 2).first)
RewardCondition.create!(rank: 4, size_min: 129, size_max: 1024, points: 288, reward: Reward.by_level(6, 3).first)
RewardCondition.create!(rank: 3, size_min: 129, size_max: 1024, points: 384, reward: Reward.by_level(6, 4).first)
RewardCondition.create!(rank: 2, size_min: 129, size_max: 1024, points: 576, reward: Reward.by_level(6, 5).first)
RewardCondition.create!(rank: 1, size_min: 129, size_max: 1024, points: 1152, reward: Reward.by_level(6, 6).first)

ENV['NO_DISCORD'] = '0'
