require 'swagger_helper'

describe 'Players API', swagger_doc: 'v1/swagger.json' do

  before do
    @token = ApiToken.create!(name: 'Player tests')
    @teams = FactoryBot.create_list(:team, 5)
    @characters = FactoryBot.create_list(:character, 5)
    @cities = FactoryBot.create_list(:city, 3)
    @first_creator_discord_id = '777'
    @players = (1..20).map do |i|
      FactoryBot.create(
        :player,
        characters: @characters.sample((0..3).to_a.sample),
        city: ([nil]+@cities).sample,
        team: ([nil]+@teams).sample,
        creator_discord_id: @first_creator_discord_id
      )
    end
    @fetched_player = Player.last
    @existing_discord_user = DiscordUser.create!(discord_id: '666')
    @players.first.update_attribute :discord_user, @existing_discord_user
    @new_discord_id = '123456789'
    @other_new_discord_id = '123123'
    @valid_player_attributes = FactoryBot.attributes_for(
      :player,
      character_ids: @characters.sample((0..3).to_a.sample).map(&:id),
      city_id: ([nil]+@cities).sample&.id,
      team_id: ([nil]+@teams).sample&.id,
      discord_id: @new_discord_id,
      creator_discord_id: @other_new_discord_id
    )
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
          player = Player.find(data.first['id'])
          target = JSON.parse(player.to_json)
          expect(data.first).to include(target)
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
      parameter name: :player_json, in: :body, schema: {
        type: :object,
        properties: {
          player: {
            '$ref' => '#/components/schemas/player_payload'
          }
        }
      }

      response '201', 'Player created' do
        let(:Authorization) { "Bearer #{@token.token}" }
        schema '$ref' => '#/components/schemas/player'

        context 'Acceptable attributes' do
          let(:player_json) do
            {
              player: @valid_player_attributes
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body).deep_symbolize_keys
            expect(data[:name]).to eq(@valid_player_attributes[:name])

            expect(DiscordUser.count).to eq(4)

            created_player_discord_user = DiscordUser.find_by(discord_id: @new_discord_id)
            expect(created_player_discord_user).to be_instance_of(DiscordUser)
            expect(data[:discord_user_id]).to eq(created_player_discord_user.id)

            created_creator_discord_user = DiscordUser.find_by(discord_id: @other_new_discord_id)
            expect(created_creator_discord_user).to be_instance_of(DiscordUser)
            expect(data[:creator_id]).to eq(created_creator_discord_user.id)

            player = Player.find(data[:id])
            target = JSON.parse(player.to_json).deep_symbolize_keys
            expect(data).to include(target)
          end
        end

        context 'Name already taken with confirmation' do
          let(:player_json) do
            {
              player: @valid_player_attributes.merge(
                name: Player.last.name,
                name_confirmation: true
              )
            }
          end

          run_test!
        end
      end

      response 422, 'unprocessable entity' do

        context 'Missing attributes' do
          let(:Authorization) { "Bearer #{@token.token}" }
          let(:player_json) do
            {
              player: @valid_player_attributes.merge(
                name: ''
              )
            }
          end
          schema '$ref' => '#/components/schemas/errors_object'

          run_test! do |response|
            data = JSON.parse(response.body).deep_symbolize_keys
            expect(data[:errors]).to have_key(:name)
          end
        end

        context 'Discord ID already taken' do
          let(:Authorization) { "Bearer #{@token.token}" }
          let(:player_json) do
            {
              player: @valid_player_attributes.merge(
                discord_id: @existing_discord_user.discord_id
              )
            }
          end
          schema '$ref' => '#/components/schemas/errors_object'

          run_test! do |response|
            data = JSON.parse(response.body).deep_symbolize_keys
            expect(data[:errors]).to have_key(:discord_user)
          end
        end

        context 'Name already taken without confirmation' do
          let(:Authorization) { "Bearer #{@token.token}" }
          let(:player_json) do
            {
              player: @valid_player_attributes.merge(
                name: Player.last.name
              )
            }
          end
          schema '$ref' => '#/components/schemas/errors_object'

          run_test! do |response|
            data = JSON.parse(response.body).deep_symbolize_keys
            expect(data[:errors]).to have_key(:name)
            expect(data[:errors]).to have_key(:existing_ids)
          end
        end

      end
    end

  end


  path '/api/v1/players/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Fetches a player' do
      tags 'Players'
      produces 'application/json'

      response '200', 'player found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        let(:id) { @fetched_player.id }
        schema '$ref' => '#/components/schemas/player'

        run_test! do |response|
          data = JSON.parse(response.body)
          target = JSON.parse(@fetched_player.to_json)
          expect(data).to include(target)
        end
      end

      response 401, 'invalid credentials' do
        let(:Authorization) { 'Bearer faketoken' }
        let(:id) { @fetched_player.id }
        run_test!
      end
    end

  end

end
