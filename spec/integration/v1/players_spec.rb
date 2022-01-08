require 'swagger_helper'

describe 'Players API', swagger_doc: 'v1/swagger.json' do

  before do
    @token = ApiToken.create!(name: 'Player tests')
    @teams = FactoryBot.create_list(:team, 5)
    @characters = FactoryBot.create_list(:character, 5)
    @first_creator_discord_id = '777'
    @admin_discord_user = FactoryBot.create(:discord_user)
    @admin_user = FactoryBot.create(
      :user,
      discord_user: @admin_discord_user,
      admin_level: Ability::ADMIN_LEVEL_HELP
    )
    @players = (1..20).map do |i|
      FactoryBot.create(
        :player,
        characters: @characters.sample((1..3).to_a.sample),
        teams: @teams.sample((0..3).to_a.sample),
        creator_discord_id: @first_creator_discord_id
      )
    end
    @fetched_player = Player.last
    @existing_discord_user = DiscordUser.create!(discord_id: '666')
    @existing_user = @existing_discord_user.return_or_create_user!
    @players.first.update_attribute :user, @existing_user
    @new_discord_id = '123456789'
    @other_new_discord_id = '123123'
    @valid_player_attributes = FactoryBot.attributes_for(
      :player,
      character_ids: @characters.sample((1..3).to_a.sample).map(&:id),
      team_ids: @teams.sample((0..3).to_a.sample).map(&:id),
      discord_id: @new_discord_id,
      creator_discord_id: @other_new_discord_id
    )
  end

  path '/api/v1/players' do

    get 'Fetches players' do
      tags 'Players'
      produces 'application/json'
      parameter name: :by_name,
                in: :query,
                type: :string,
                required: false,
                description: 'Search by exact name (case-sensitive)'
      parameter name: :by_name_like,
                in: :query,
                type: :string,
                required: false,
                description: 'Search by similar name (ignoring case and accents)'
      parameter name: :by_discord_id,
                in: :query,
                type: :string,
                required: false,
                description: 'Search by Discord ID. Use an empty value to search for players without a Discord ID'
      parameter name: :page,
                in: :query,
                type: :integer,
                required: false,
                description: 'Select page for offset search (default = 1)'
      parameter name: :per,
                in: :query,
                type: :integer,
                required: false,
                description: 'Select page size for offset search (default = 25)'
      parameter name: :on_abc,
                in: :query,
                type: :string,
                required: false,
                description: "Search by name initial (ignoring case). Use '$' to search for all other initial values (numbers, symbols, etc.)"

      response '200', 'players found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        schema '$ref' => '#/components/schemas/players_array'

        context 'without filters' do
          run_test! do |response|
            data = JSON.parse(response.body).map(&:deep_symbolize_keys)
            expect(data.count).to eq(Player.count)
            player = Player.find(data.first[:id])
            target = JSON.parse(player.to_json).deep_symbolize_keys
            expect(data.first).to include(target)
          end
        end

        context 'with name filter' do
          let(:player) { Player.last }
          let(:by_name) { CGI.escape(player.name) }

          run_test! do |response|
            data = JSON.parse(response.body).map(&:deep_symbolize_keys)
            expect(data.count).to eq(Player.where(name: player.name).count)
            expect(data.first[:id]).to eq(player.id)
          end
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

            player = Player.find(data[:id])
            expect(player.is_accepted).to be_falsey

            created_player_discord_user = DiscordUser.find_by(discord_id: @new_discord_id)
            expect(created_player_discord_user).to be_instance_of(DiscordUser)
            expect(player.discord_user).to eq(created_player_discord_user)

            created_creator_user = DiscordUser.find_by(discord_id: @other_new_discord_id).user
            expect(created_creator_user).to be_instance_of(User)
            expect(player.creator_user).to eq(created_creator_user)

            expect(player.character_ids).to eq(@valid_player_attributes[:character_ids])
            expect(player.team_ids).to eq(@valid_player_attributes[:team_ids])

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
            expect(player.creator_user).to eq(@admin_user)
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
            expect(data[:errors][:name]).to eq(['blank'])
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
            expect(data[:errors]).to have_key(:user_id)
            expect(data[:errors][:user_id]).to eq(['already_taken'])
          end
        end

        context 'Name already taken without confirmation' do
          let(:Authorization) { "Bearer #{@token.token}" }
          let(:existing_player) { Player.last }
          let(:player_json) do
            {
              player: @valid_player_attributes.merge(
                name: existing_player.name
              )
            }
          end
          schema '$ref' => '#/components/schemas/errors_object'

          run_test! do |response|
            data = JSON.parse(response.body).deep_symbolize_keys
            expect(data[:errors]).to have_key(:name)
            expect(data[:errors][:name]).to eq('already_known')
            expect(data[:errors]).to have_key(:existing_ids)
            expect(data[:errors][:existing_ids]).to eq([existing_player.id])
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
          let(:player) { Player.with_user.last }
          let(:id) { player.id }
          let(:player_json) do
            {
              player: {
                discord_id: nil
              }
            }
          end

          run_test! do
            player.reload
            expect(player.user.discord_user).to be_nil
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
