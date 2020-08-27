# require 'graphql/client'
require 'graphql/client/http'

class SmashGGClient

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

  # def tournaments
  #   SmashGGAPI::Client.query(
  #     SmashGGAPI::Client.parse <<-'GRAPHQL'
  #       query($countryCode: String, $perPage: Int!) {
  #         tournaments(query: {
  #           perPage: $perPage
  #           filter: {
  #             countryCode: $countryCode
  #           }
  #         }) {
  #           nodes {
  #             id
  #             name
  #             countryCode
  #           }
  #         }
  #       }
  #     GRAPHQL,
  #     variables: {
  #       countryCode: 'FR',
  #       perPage: 5
  #     }
  #   )
  # end

end
