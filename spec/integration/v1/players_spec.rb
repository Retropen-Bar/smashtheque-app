require 'swagger_helper'

describe 'Players API', swagger_doc: 'v1/swagger.json' do

  before do
    @token = ApiToken.create!(name: 'Player tests')
    @teams = FactoryBot.create_list(:team, 5)
    @characters = FactoryBot.create_list(:character, 5)
    @cities = FactoryBot.create_list(:city, 3)
    @first_creator_discord_id = '777'
    @admin_discord_user = FactoryBot.create(:discord_user)
    @admin_user = AdminUser.create(discord_user: @admin_discord_user)
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

            expect(DiscordUser.count).to eq(5)

            player = Player.find(data[:id])
            expect(player.is_accepted).to be_falsey

            created_player_discord_user = DiscordUser.find_by(discord_id: @new_discord_id)
            expect(created_player_discord_user).to be_instance_of(DiscordUser)
            expect(player.discord_user).to eq(created_player_discord_user)

            created_creator_discord_user = DiscordUser.find_by(discord_id: @other_new_discord_id)
            expect(created_creator_discord_user).to be_instance_of(DiscordUser)
            expect(player.creator).to eq(created_creator_discord_user)

            player = Player.find(data[:id])
            target = JSON.parse(player.to_json).deep_symbolize_keys
            expect(data).to include(target)
          end
        end

        context 'Created by an admin' do
          let(:player_json) do
            {
              player: @valid_player_attributes.merge(
                creator_discord_id: @admin_discord_user.discord_id
              )
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body).deep_symbolize_keys
            player = Player.find(data[:id])
            expect(player.is_accepted).to be_truthy
            expect(player.creator).to eq(@admin_discord_user)
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

      response 404, 'not found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        let(:id) { Player.last.id + 1 }
        run_test!
      end
    end

    patch 'Updates a player' do
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

      response '200', 'Player updated' do
        let(:Authorization) { "Bearer #{@token.token}" }
        let(:player) { Player.last }
        let(:id) { player.id }
        schema '$ref' => '#/components/schemas/player'

        context 'Acceptable name' do
          let(:new_name) { player.name + '_mod' }
          let(:player_json) do
            {
              player: {
                name: new_name
              }
            }
          end

          run_test! do |response|
            player.reload
            expect(player.name).to eq(new_name)
            # TODO: try to update more attributes
            data = JSON.parse(response.body).deep_symbolize_keys
            target = JSON.parse(player.to_json).deep_symbolize_keys
            expect(data).to include(target)
          end
        end

        context 'Name included but not changed' do
          let(:player_json) do
            {
              player: {
                name: player.name
              }
            }
          end

          run_test!
        end

        context 'Name already taken with confirmation' do
          let(:player_json) do
            {
              player: {
                name: Player.first.name,
                name_confirmation: true
              }
            }
          end

          run_test!
        end

        context 'Removing Discord ID' do
          let(:player) { Player.with_discord_user.last }
          let(:id) { player.id }
          let(:player_json) do
            {
              player: {
                discord_id: nil
              }
            }
          end

          run_test! do |response|
            player.reload
            expect(player.discord_user).to be_nil
          end
        end
      end

      response 422, 'unprocessable entity' do
        let(:Authorization) { "Bearer #{@token.token}" }
        let(:player) { Player.last }
        let(:id) { player.id }
        schema '$ref' => '#/components/schemas/errors_object'

        context 'Empty name' do
          let(:player_json) do
            {
              player: {
                name: ''
              }
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body).deep_symbolize_keys
            expect(data[:errors]).to have_key(:name)
          end
        end

        context 'Name already taken without confirmation' do
          let(:player_json) do
            {
              player: {
                name: Player.first.name
              }
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body).deep_symbolize_keys
            expect(data[:errors]).to have_key(:name)
            expect(data[:errors]).to have_key(:existing_ids)
          end
        end
      end

      response 401, 'invalid credentials' do
        let(:Authorization) { 'Bearer faketoken' }
        let(:id) { Player.last.id }
        let(:player_json) { {} }
        run_test!
      end

      response 404, 'not found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        let(:id) { Player.last.id + 1 }
        let(:player_json) { {} }
        run_test!
      end
    end

  end

end
