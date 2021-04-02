require 'swagger_helper'

describe 'PlayersRecurringTournaments API', swagger_doc: 'v1/swagger.json' do

  before do
    @token = FactoryBot.create(:api_token)
    @recurring_tournament = FactoryBot.create(:recurring_tournament)
    @creator_user = FactoryBot.create(:user)
    @player1 = FactoryBot.create(:player, creator_user: @creator_user)
    @player2 = FactoryBot.create(:player, creator_user: @creator_user)
    @player3 = FactoryBot.create(:player, creator_user: @creator_user)
    @other_discord_user = FactoryBot.create(:discord_user)
    @player4 = FactoryBot.create(:player, creator_user: @creator_user,
                                          discord_id: @other_discord_user.discord_id)
    PlayersRecurringTournament.delete_all
    @existing_players_recurring_tournament = PlayersRecurringTournament.create(
      recurring_tournament: @recurring_tournament,
      player: @player1,
      has_good_network: true
    )
    @certifier_user = FactoryBot.create(:user)
    @certifier_discord_user = FactoryBot.create(:discord_user, user: @certifier_user)
  end

  path '/api/v1/recurring_tournaments/{recurring_tournament_id}/players/{player_id}' do
    parameter name: :recurring_tournament_id, in: :path, type: :integer, required: true
    parameter name: :player_id, in: :path, type: :integer, required: true

    put 'Updates a PlayersRecurringTournament' do
      tags 'PlayersRecurringTournament'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :players_recurring_tournament_json, in: :body, schema: {
        type: :object,
        properties: {
          '$ref' => '#/components/schemas/players_recurring_tournament_payload'
        }
      }

      response 200, 'PlayersRecurringTournament updated' do
        let(:Authorization) { "Bearer #{@token.token}" }
        let(:recurring_tournament_id) { @recurring_tournament.id }
        schema '$ref' => '#/components/schemas/players_recurring_tournament'

        context 'Already existing' do
          let(:player_id) { @player1.id }
          let(:players_recurring_tournament_json) do
            {
              has_good_network: false
            }
          end

          run_test! do |response|
            @existing_players_recurring_tournament.reload
            expect(PlayersRecurringTournament.count).to eq(1)
            expect(@existing_players_recurring_tournament.has_good_network).to be_falsey
          end
        end

        context 'Not already existing' do
          let(:player_id) { @player2.id }
          let(:players_recurring_tournament_json) do
            {
              has_good_network: true
            }
          end

          run_test! do |response|
            expect(PlayersRecurringTournament.count).to eq(2)
            players_recurring_tournament = PlayersRecurringTournament.last
            expect(players_recurring_tournament.player_id).to eq(@player2.id)
            expect(players_recurring_tournament.has_good_network).to be_truthy
          end
        end

        context 'With certifier' do
          let(:player_id) { @player3.id }
          let(:players_recurring_tournament_json) do
            {
              has_good_network: true,
              certifier_user_id: @certifier_user.id
            }
          end

          run_test! do |response|
            expect(PlayersRecurringTournament.count).to eq(2)
            players_recurring_tournament = PlayersRecurringTournament.last
            expect(players_recurring_tournament.player_id).to eq(@player3.id)
            expect(players_recurring_tournament.certifier_user_id).to eq(@certifier_user.id)
          end
        end
      end

      response 401, 'Invalid credentials' do
        let(:Authorization) { 'Bearer faketoken' }
        let(:recurring_tournament_id) { @recurring_tournament.id }
        let(:player_id) { @player1.id }
        let(:players_recurring_tournament_json) do
          {
            has_good_network: true
          }
        end
        run_test!
      end

      response 422, 'unprocessable entity' do
        let(:Authorization) { "Bearer #{@token.token}" }
        let(:recurring_tournament_id) { @recurring_tournament.id }
        let(:player_id) { @player1.id }

        context 'Missing has_good_network' do
          let(:players_recurring_tournament_json) do
            {
              certifier_user_id: @certifier_user.id
            }
          end
          schema '$ref' => '#/components/schemas/errors_object'

          run_test! do |response|
            data = JSON.parse(response.body).deep_symbolize_keys
            expect(data[:errors]).to have_key(:has_good_network)
            expect(data[:errors][:has_good_network]).to eq(['required'])
          end
        end
      end
    end
  end

  path '/api/v1/recurring_tournaments/{recurring_tournament_id}/discord_users/{discord_id}' do
    parameter name: :recurring_tournament_id, in: :path, type: :integer, required: true
    parameter name: :discord_id, in: :path, type: :integer, required: true

    put 'Updates a PlayersRecurringTournament' do
      tags 'PlayersRecurringTournament'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :players_recurring_tournament_json, in: :body, schema: {
        type: :object,
        properties: {
          '$ref' => '#/components/schemas/players_recurring_tournament_payload'
        }
      }

      response 200, 'PlayersRecurringTournament updated' do
        let(:Authorization) { "Bearer #{@token.token}" }
        let(:recurring_tournament_id) { @recurring_tournament.id }
        let(:discord_id) { @player4.discord_id }
        let(:players_recurring_tournament_json) do
          {
            has_good_network: true,
            certifier_discord_id: @certifier_discord_user.discord_id
          }
        end
        schema '$ref' => '#/components/schemas/players_recurring_tournament'

        run_test! do |response|
          expect(PlayersRecurringTournament.count).to eq(2)
          players_recurring_tournament = PlayersRecurringTournament.last
          expect(players_recurring_tournament.player_id).to eq(@player4.id)
          expect(players_recurring_tournament.has_good_network).to be_truthy
          expect(players_recurring_tournament.certifier_user_id).to eq(@certifier_user.id)
        end
      end
    end
  end

end
