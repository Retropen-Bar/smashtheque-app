require 'swagger_helper'

describe 'Cities API', swagger_doc: 'v1/swagger.json' do

  before do
    @token = ApiToken.create!(name: 'City tests')
    @cities = (1..3).map do |i|
      FactoryBot.create(:city)
    end
  end

  path '/api/v1/cities' do

    get 'Fetches cities' do
      tags 'Cities'
      consumes 'application/json'
      # parameter name: :page, in: :query, type: :string

      response '200', 'cities found' do
        let(:Authorization) { "Bearer #{@token.token}" }
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
