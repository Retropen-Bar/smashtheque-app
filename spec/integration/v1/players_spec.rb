require 'swagger_helper'

describe 'Players API', swagger_doc: 'v1/swagger.json' do

  before do
    @token = ApiToken.create!(name: 'Player tests')
    @teams = FactoryBot.create_list(:team, 5)
    @characters = FactoryBot.create_list(:character, 5)
    @cities = FactoryBot.create_list(:city, 3)
    @players = (1..20).map do |i|
      FactoryBot.create(
        :player,
        characters: @characters.sample((0..3).to_a.sample),
        city: ([nil]+@cities).sample,
        team: ([nil]+@teams).sample
      )
    end
  end

  path '/api/v1/players' do

    get 'Fetches players' do
      tags 'Players'
      produces 'application/json'
      # parameter name: :page, in: :query, type: :string

      response '200', 'players found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 123 },
              name: { type: :string, example: 'Pixel' },
              city_id: { type: :integer, nullable: true, example: 42 },
              team_id: { type: :integer, nullable: true, example: 13 },
              character_ids: {
                type: :array,
                items: {
                  type: :integer
                },
                example: [7,25]
              }
            }
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.count).to eq(20)
          # TODO: test more data
        end
      end

      response 401, 'invalid credentials' do
        let(:Authorization) { 'Bearer faketoken' }
        run_test!
      end
    end

    # post 'Creates a player' do
    #   tags 'Players'
    #   consumes 'application/json'

    #   response 422, 'invalid request' do
    #     let(:Authorization) { "Bearer #{@token.token}" }
    #     schema '$ref' => '#/components/schemas/errors_object'
    #     run_test!
    #   end
    # end

  end


end
