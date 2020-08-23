require 'swagger_helper'

describe 'Characters API', swagger_doc: 'v1/swagger.json' do

  before do
    @token = ApiToken.create!(name: 'Character tests')
    @characters = FactoryBot.create_list(:character, 5)
  end

  path '/api/v1/characters' do

    get 'Fetches characters' do
      tags 'Characters'
      produces 'application/json'
      # parameter name: :page, in: :query, type: :string

      response '200', 'characters found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        schema '$ref' => '#/components/schemas/characters_array'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.count).to eq(5)
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
