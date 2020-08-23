require 'swagger_helper'

describe 'Cities API', swagger_doc: 'v1/swagger.json' do

  before do
    @token = ApiToken.create!(name: 'City tests')
    @cities = FactoryBot.create_list(:city, 3)
  end

  path '/api/v1/cities' do

    get 'Fetches cities' do
      tags 'Cities'
      produces 'application/json'
      # parameter name: :page, in: :query, type: :string

      response '200', 'cities found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 13 },
              name: { type: :string, example: 'Paris' },
              icon: { type: :string, example: '🌳' }
            }
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.count).to eq(3)
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
