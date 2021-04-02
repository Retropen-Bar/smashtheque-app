# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.json' => {
      openapi: '3.0.1',
      info: {
        title: 'Smashthèque API',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'www.example.com'
            }
          }
        }
      ],
      components: {
        schemas: {
          character: {
            type: :object,
            properties: {
              id: { type: :integer },
              icon: { type: :string, example: '👊' },
              name: { type: :string, example: 'Terry' },
              emoji: { type: :string, example: '739087535812116572' }
            }
          },
          characters_array: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/character'
            }
          },
          community: {
            type: :object,
            properties: {
              id: { type: :integer, example: 13 },
              name: { type: :string, example: 'Paris' }
            }
          },
          communities_array: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/community'
            }
          },
          player_payload: {
            type: :object,
            properties: {
              creator_discord_id: { type: :string, nullable: true, example: '608210202952466464' },
              name: { type: :string, example: 'Pixel' },
              team_id: { type: :integer, nullable: true, example: 13 },
              discord_id: { type: :string, nullable: true, example: '608210202952466464' },
              character_ids: {
                type: :array,
                items: {
                  type: :integer
                },
                example: [7,25]
              }
            }
          },
          player: {
            type: :object,
            properties: {
              id: { type: :integer, example: 123 },
              name: { type: :string, example: 'Pixel' },
              is_accepted: { type: :boolean, nullable: true, example: true },
              created_at: { type: :string, example: '2020-08-23T23:05:16.671Z' },
              updated_at: { type: :string, example: '2020-08-24T17:47:04.630Z' },

              character_ids: {
                type: :array,
                items: {
                  type: :integer
                },
                example: [7, 25]
              },
              character_names: {
                type: :array,
                items: {
                  type: :string
                },
                example: ['yoshi', 'bowser']
              },
              characters: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer, example: 7 },
                    name: { type: :string, example: 'yoshi' },
                    emoji: { type: :string, example: '737480513744273500' }
                  }
                },
                example: [
                  {
                    id: 7,
                    name: 'yoshi',
                    emoji: '737480513744273500'
                  },
                  {
                    id: 25,
                    name: 'bowser',
                    emoji: '737480497332224100'
                  }
                ]
              },

              creator_discord_id: { type: :string, example: '608210202952466464' },
              creator_id: { type: :integer, example: 7 },
              creator: {
                type: :object,
                properties: {
                  id: { type: :integer, example: 7 },
                  discord_id: { type: :string, example: '608210202952466464' }
                }
              },

              discord_id: { type: :string, nullable: true, example: '608210202952466464' },
              discord_user_id: { type: :integer, nullable: true, example: 7 },
              discord_user: {
                type: :object,
                nullable: true,
                properties: {
                  id: { type: :integer, example: 7 },
                  discord_id: { type: :string, example: '608210202952466464' }
                }
              },

              team_id: { type: :integer, nullable: true, example: 13 },
              team: {
                type: :object,
                nullable: true,
                properties: {
                  id: { type: :integer, example: 13 },
                  name: { type: :string, example: 'Rétropen-Bar' }
                }
              }
            }
          },
          players_array: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/player'
            }
          },
          players_recurring_tournament: {
            type: :object,
            properties: {
              recurring_tournamen_id: { type: :integer, example: 7 },
              player_id: { type: :integer, example: 42 },
              has_good_network: { type: :boolean, example: true },
              certifier_user_id: { type: :integer, nullable: true, example: 13 }
            }
          },
          players_recurring_tournament_payload: {
            type: :object,
            properties: {
              has_good_network: { type: :boolean, example: true },
              certifier_user_id: { type: :integer, nullable: true, example: 13 }
            }
          },
          error: {
            type: :object
          },
          errors_object: {
            type: :object,
            properties: {
              errors: {
                '$ref' => '#/components/schemas/error'
              }
            }
          },
          team: {
            type: :object,
            properties: {
              id: { type: :integer, example: 27 },
              name: { type: :string, example: 'Rétropen-Bar' },
              short_name: { type: :string, example: 'R-B' }
            }
          },
          teams_array: {
            type: :array,
            items: {
              '$ref' => '#/components/schemas/team'
            }
          }
        },
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer
          }
        }
      },
      security: [
        {
          bearerAuth: []
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :json
end
