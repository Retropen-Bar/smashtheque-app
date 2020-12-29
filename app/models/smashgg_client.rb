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

  def get_user_data(user_id)
    response = CLIENT.query(
      UserDataQuery,
      variables: {
        userId: user_id
      }
    )
    response.data
  end

  TournamentDataBySlugQuery =
    CLIENT.parse <<-'GRAPHQL'
      query($tournamentSlug: String) {
        tournament(slug: $tournamentSlug) {
          id
          slug
          name
          startAt
          events {
            id
            name
            startAt
            isOnline
            numEntrants
          }
        }
      }
    GRAPHQL

  def get_tournament_data(slug:)
    response = CLIENT.query(
      TournamentDataBySlugQuery,
      variables: {
        tournamentSlug: slug
      }
    )
    response.data
  end

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

  def get_event_data(id: nil, slug: nil)
    response =
      if id
        CLIENT.query(
          EventDataByIdQuery,
          variables: {
            eventId: id
          }
        )
      elsif slug
        CLIENT.query(
          EventDataBySlugQuery,
          variables: {
            eventSlug: slug
          }
        )
      else
        nil
      end
    response&.data
  end

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

  def get_events_data(name:, from:, to:)
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
