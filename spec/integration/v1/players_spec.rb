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
      consumes 'application/json'
      # parameter name: :page, in: :query, type: :string

      response '200', 'players found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.count).to eq(20)
          # TODO: test more data
        end
      end

      response '401', 'Invalid credentials' do
        let(:Authorization) { 'Bearer faketoken' }
        run_test!
      end
    end
  end

end
