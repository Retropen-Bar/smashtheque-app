GUILD_ID = '737431333478989907'
PARTICIPANT_ROLE_ID = '957901704815345664'
EVENT_SLUG = 'tournament/tales-of-smash-lcq-x-smashth-que/event/tales-of-smash-lcq-x-smashth-que'

GraphData =
  SmashggClient::CLIENT.parse <<-GRAPHQL
    query($slug: String) {
      event(slug: $slug){
        entrants(query: {perPage: 500}) {
          nodes {
            name
            participants {
              user {
                id
                slug
              }
              requiredConnections {
                externalId
              }
            }
          }
        }
      }
    }
  GRAPHQL

response = SmashggClient::CLIENT.query(
  GraphData,
  variables: {
    slug: EVENT_SLUG
  }
)

players = response.data.event.entrants.nodes.filter_map do |entrant|
  if entrant.participants.first.required_connections.first&.external_id
    {
      name: entrant.name,
      smashgg_user_id: entrant.participants.first.user.id,
      smashgg_user_slug: entrant.participants.first.user.slug,
      discord_id: entrant.participants.first.required_connections.first.external_id
    }
  end
end

players.sort_by! { |player| player[:smashgg_user_id] }

# add @smashtheque_player_id
players.each do |player|
  discord_user = DiscordUser.where(discord_id: player[:discord_id]).first
  if discord_user&.player
    player[:smashtheque_player_id] = discord_user.player.id
    next
  end

  smashgg_user = SmashggUser.where(slug: player[:smashgg_user_slug]).first
  if smashgg_user&.player
    player[:smashtheque_player_id] = smashgg_user.player.id
  end
end

# use @smashtheque_player_id
players.each do |player|
  if player[:smashtheque_player_id]
    smashtheque_player = Player.find(player[:smashtheque_player_id])
    player[:track_records] = {
      all: {
        online: {
          rank: smashtheque_player.rank(is_online: true),
          points:  smashtheque_player.points(is_online: true)
        },
        offline: {
          rank: smashtheque_player.rank(is_online: false),
          points:  smashtheque_player.points(is_online: false)
        }
      }
    }
    TrackRecord.points_years.each do |year|
      player[:track_records][year] = {
        online: {
          rank: smashtheque_player.rank(is_online: true, year: year),
          points: smashtheque_player.points(is_online: true, year: year)
        },
        offline: {
          rank: smashtheque_player.rank(is_online: false, year: year),
          points: smashtheque_player.points(is_online: false, year: year)
        }
      }
    end
  end
end

# print
players.each do |player|
  line = [
    player[:smashgg_user_id],
    "https://www.start.gg/#{player[:smashgg_user_slug]}",
    player[:name],
    player[:smashtheque_player_id]
  ]
  if player[:smashtheque_player_id]
    line << [
      "https://www.smashtheque.fr/players/#{player[:smashtheque_player_id]}",
      player[:track_records][:all][:online][:rank],
      player[:track_records][:all][:online][:points],
      player[:track_records][2021][:online][:rank],
      player[:track_records][2022][:online][:rank]
    ]
  end
  puts line.join("\t")
end; nil







players.each do |player|
  discord_user = DiscordUser.where(discord_id: player[:discord_id]).first_or_create

  SmashggUser.where(slug: player[:smashgg_user_slug]).first_or_create
end; nil
