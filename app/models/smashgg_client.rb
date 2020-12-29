# require 'graphql/client'
require 'graphql/client/http'

class SmashggClient

  HTTP = GraphQL::Client::HTTP.new('https://api.smash.gg/gql/alpha') do
    def headers(context)
      {
        Authorization: "Bearer #{ENV['SMASHGG_API_TOKEN']}"
      }
    end
  end

  SCHEMA = GraphQL::Client.load_schema(HTTP)

  CLIENT = GraphQL::Client.new(schema: SCHEMA, execute: HTTP)

  UserDataQuery =
    CLIENT.parse <<-'GRAPHQL'
      query($userId: ID) {
        user(id: $userId) {
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
        }
      }
    GRAPHQL

  TournamentEventsDataBySlugQuery =
    CLIENT.parse <<-'GRAPHQL'
      query($tournamentSlug: String) {
        tournament(slug: $tournamentSlug) {
          events {
            id
            slug
            name
            startAt
            isOnline
            numEntrants
            tournament {
              id
              slug
              name
            }
          }
        }
      }
    GRAPHQL

  EventDataByIdQuery =
    CLIENT.parse <<-'GRAPHQL'
      query($eventId: ID) {
        event(id: $eventId) {
          id
          slug
          name
          startAt
          isOnline
          numEntrants
          tournament {
            id
            slug
            name
          }
        }
      }
    GRAPHQL

  EventDataBySlugQuery =
    CLIENT.parse <<-'GRAPHQL'
      query($eventSlug: String) {
        event(slug: $eventSlug) {
          id
          slug
          name
          startAt
          isOnline
          numEntrants
          tournament {
            id
            slug
            name
          }
        }
      }
    GRAPHQL

  TournamentsSearchQuery =
    CLIENT.parse <<-'GRAPHQL'
      query($name: String, $dateMin: Timestamp, $dateMax: Timestamp) {
        tournaments(query: {
          perPage: 100
          sortBy: "startAt asc"
          filter: {
            hasOnlineEvents: true
            videogameIds: [1386]
            name: $name
            afterDate: $dateMin
            beforeDate: $dateMax
          }
        }) {
          nodes {
            events {
              id
              slug
              name
              startAt
              isOnline
              numEntrants
              tournament {
                id
                slug
                name
              }
            }
          }
        }
      }
    GRAPHQL

  def get_user(user_id:)
    response = CLIENT.query(
      UserDataQuery,
      variables: {
        userId: user_id
      }
    )
    response.data
  end

  def get_tournament_events(tournament_slug:)
    CLIENT.query(
      TournamentEventsDataBySlugQuery,
      variables: {
        tournamentSlug: tournament_slug
      }
    ).data.tournament.events
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

  def get_events(name:, from:, to:)
    response = CLIENT.query(
      TournamentsSearchQuery,
      variables: {
        name: name,
        dateMin: from.to_time.to_i,
        dateMax: to.to_time.to_i
      }
    )
    result = []
    response.data.tournaments.nodes&.each do |node|
      result += node.events
    end
    result
  end

end
