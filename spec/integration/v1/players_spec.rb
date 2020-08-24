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
          expect(data.first.symbolize_keys).to include(
            id: player.id,
            city_id: player.city_id,
            team_id: player.team_id,
            name: player.name,
            is_accepted: player.is_accepted,
            discord_user_id: player.discord_user_id,
            discord_id: player.discord_id,
            character_names: player.character_names,
            creator_id: player.creator_id,
            creator_discord_id: player.creator_discord_id
          )
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
        let(:player_json) do
          {
            player: @valid_player_attributes
          }
        end
        schema '$ref' => '#/components/schemas/player'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq(@valid_player_attributes[:name])

          expect(DiscordUser.count).to eq(4)

          created_player_discord_user = DiscordUser.find_by(discord_id: @new_discord_id)
          expect(created_player_discord_user).to be_instance_of(DiscordUser)
          expect(data['discord_user_id']).to eq(created_player_discord_user.id)

          created_creator_discord_user = DiscordUser.find_by(discord_id: @other_new_discord_id)
          expect(created_creator_discord_user).to be_instance_of(DiscordUser)
          expect(data['creator_id']).to eq(created_creator_discord_user.id)

          # TODO: test more data
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
            data = JSON.parse(response.body)
            expect(data['errors']).to have_key('name')
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
            data = JSON.parse(response.body)
            expect(data['errors']).to have_key('discord_user')
          end
        end

      end
    end

  end


end
