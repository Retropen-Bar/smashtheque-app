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
    @valid_player = FactoryBot.attributes_for(
      :player,
      character_id: @characters.sample((0..3).to_a.sample).map(&:id),
      city_id: ([nil]+@cities).sample&.id,
      team_id: ([nil]+@teams).sample&.id
    )
    @invalid_player = {
      name: ''
    }
  end

  path '/api/v1/players' do

    get 'Fetches players' do
      tags 'Players'
      produces 'application/json'
      # parameter name: :page, in: :query, type: :string

      response '200', 'players found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        schema '$ref' => '#/components/schemas/players_array'

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

    post 'Creates a player' do
      tags 'Players'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :player, in: :body, schema: { '$ref' => '#/components/schemas/player_payload' }

      response '201', 'Player created' do
        let(:Authorization) { "Bearer #{@token.token}" }
        let(:player) { @valid_player }
        schema '$ref' => '#/components/schemas/player'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq(@valid_player[:name])
          # TODO: test more data
        end
      end

      response 422, 'invalid request' do
        let(:Authorization) { "Bearer #{@token.token}" }
        let(:player) { @invalid_player }
        schema '$ref' => '#/components/schemas/errors_object'
        run_test!
      end
    end

  end


end
