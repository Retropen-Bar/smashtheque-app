require 'graphql/client/http'

# ideas:
# - use "state" to fetch only COMPLETED events
# - fetch more than 100 events (maybe useless now since we fetch most recent first)

class SmashggClient
  HTTP = GraphQL::Client::HTTP.new('https://api.start.gg/gql/alpha') do
    def headers(context)
      {
        Authorization: "Bearer #{ENV['SMASHGG_API_TOKEN']}"
      }
    end
  end

  SCHEMA = GraphQL::Client.load_schema(HTTP)

  CLIENT = GraphQL::Client.new(schema: SCHEMA, execute: HTTP)

  SMASH_ULTIMATE_ID = '1386'.freeze
  EVENT_TYPE_1V1 = 1

  UserData =
    <<-GRAPHQL
      id
      slug
      name
      bio
      birthday
      genderPronoun
      player {
        id
        gamerTag
        prefix
      }
      location {
        city
        country
        countryId
        state
        stateId
      }
      images {
        type
        url
      }
      authorizations {
        type
        externalUsername
      }
    GRAPHQL

  UserDataByIdQuery =
    CLIENT.parse <<-GRAPHQL
      query($userId: ID) {
        user(id: $userId) {
          #{UserData}
        }
      }
    GRAPHQL

  UserDataBySlugQuery =
    CLIENT.parse <<-GRAPHQL
      query($userSlug: String) {
        user(slug: $userSlug) {
          #{UserData}
        }
      }
    GRAPHQL

  EventData =
    <<-GRAPHQL
      id
      slug
      name
      startAt
      isOnline
      numEntrants
      type
      videogame {
        id
      }
      tournament {
        id
        slug
        name
        owner {
          id
          slug
        }
        lat
        lng
        primaryContactType
        primaryContact
      }
    GRAPHQL

  EventDataWithStandings =
    <<-GRAPHQL
      #{EventData}
      standings(query: {perPage: 8, sortBy: "placement"}) {
        nodes {
          placement
          entrant {
            participants {
              user {
                id
                slug
              }
            }
          }
        }
      }
    GRAPHQL

  TournamentEventsDataBySlugQuery =
    CLIENT.parse <<-GRAPHQL
      query($tournamentSlug: String) {
        tournament(slug: $tournamentSlug) {
          events(filter: {
            videogameId: #{SMASH_ULTIMATE_ID}
            type: #{EVENT_TYPE_1V1}
          }) {
            #{EventDataWithStandings}
          }
        }
      }
    GRAPHQL

  EventDataByIdQuery =
    CLIENT.parse <<-GRAPHQL
      query($eventId: ID) {
        event(id: $eventId) {
          #{EventDataWithStandings}
        }
      }
    GRAPHQL

  EventDataBySlugQuery =
    CLIENT.parse <<-GRAPHQL
      query($eventSlug: String) {
        event(slug: $eventSlug) {
          #{EventDataWithStandings}
        }
      }
    GRAPHQL

  TournamentsSearchQuery =
    CLIENT.parse <<-GRAPHQL
      query($name: String, $dateMin: Timestamp, $dateMax: Timestamp, $country: String) {
        tournaments(query: {
          perPage: 100
          sortBy: "startAt desc"
          filter: {
            name: $name
            afterDate: $dateMin
            beforeDate: $dateMax
            countryCode: $country
          }
        }) {
          nodes {
            events(filter: {
              videogameId: #{SMASH_ULTIMATE_ID}
              type: #{EVENT_TYPE_1V1}
            }) {
              #{EventData}
            }
          }
        }
      }
    GRAPHQL

  UserCompetedTournamentsSearchQuery =
    CLIENT.parse <<-GRAPHQL
      query($userId: ID) {
        user(id: $userId) {
          id
          events(query: {
            perPage: 100
            sortBy: "startAt desc"
            filter: {
              videogameId: #{SMASH_ULTIMATE_ID}
              eventType: #{EVENT_TYPE_1V1}
            }
          }) {
            nodes {
              #{EventData}
            }
          }
        }
      }
    GRAPHQL

  UserOwnedTournamentsSearchQuery =
    CLIENT.parse <<-GRAPHQL
      query($userId: ID) {
        tournaments(query: {
          perPage: 100
          sortBy: "startAt desc"
          filter: {
            ownerId: $userId
          }
        }) {
          nodes {
            events(filter: {
              videogameId: #{SMASH_ULTIMATE_ID}
              type: #{EVENT_TYPE_1V1}
            }) {
              #{EventData}
            }
          }
        }
      }
    GRAPHQL

  def get_user(user_id: nil, user_slug: nil)
    if user_id
      CLIENT.query(
        UserDataByIdQuery,
        variables: {
          userId: user_id
        }
      )&.data&.user
    elsif user_slug
      CLIENT.query(
        UserDataBySlugQuery,
        variables: {
          userSlug: user_slug
        }
      )&.data&.user
    else
      nil
    end
  end

  def get_tournament_events(tournament_slug:)
    result = []
    CLIENT.query(
      TournamentEventsDataBySlugQuery,
      variables: {
        tournamentSlug: tournament_slug
      }
    ).data.tournament.events.each do |event|
      result << event if event.videogame.id == SMASH_ULTIMATE_ID
    end
    result
  end

  def get_event(event_id: nil, event_slug: nil, tournament_slug: nil)
    if event_id
      CLIENT.query(
        EventDataByIdQuery,
        variables: {
          eventId: event_id
        }
      )&.data&.event
    elsif event_slug
      CLIENT.query(
        EventDataBySlugQuery,
        variables: {
          eventSlug: event_slug
        }
      )&.data&.event
    elsif tournament_slug
      get_tournament_events(tournament_slug: tournament_slug).first
    else
      nil
    end
  end

  def get_events(name:, from:, to:, country:)
    response = CLIENT.query(
      TournamentsSearchQuery,
      variables: {
        name: name,
        dateMin: from.to_time.to_i,
        dateMax: to.to_time.to_i,
        country: country
      }
    )
    if response.data.nil?
      puts "Start.gg error: #{response.inspect}"
      return nil
    end
    result = []
    response.data.tournaments&.nodes&.each do |node|
      node.events&.each do |event|
        result << event
      end
    end
    result
  end

  # always respond with an enumerable
  def get_user_competed_events(user_id:)
    CLIENT.query(
      UserCompetedTournamentsSearchQuery,
      variables: {
        userId: user_id
      }
    ).data&.user&.events&.nodes || []
  end

  # always respond with an enumerable
  def get_user_owned_events(user_id:)
    response = CLIENT.query(
      UserOwnedTournamentsSearchQuery,
      variables: {
        userId: user_id
      }
    )
    result = []
    response.data&.tournaments&.nodes&.each do |node|
      node.events&.each do |event|
        result << event
      end
    end
    result
  end

  # always respond with an enumerable
  def get_user_events(user_id:)
    get_user_competed_events(user_id: user_id) + get_user_owned_events(user_id: user_id)
  end
end
