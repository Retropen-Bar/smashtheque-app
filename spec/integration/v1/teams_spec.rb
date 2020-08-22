require 'swagger_helper'

describe 'Teams API', swagger_doc: 'v1/swagger.json' do

  before do
    @token = ApiToken.create!(name: 'Team tests')
    @teams = FactoryBot.create_list(:team, 5)
  end

  after do |example|
    example.metadata[:response][:examples] = {
      'application/json' => !response.body.blank? && JSON.parse(response.body, symbolize_names: true)
    }
  end

  path '/api/v1/teams' do

    get 'Fetches teams' do
      tags 'Teams'
      consumes 'application/json'
      # parameter name: :page, in: :query, type: :string

      response 200, 'teams found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              short_name: { type: :string }
            }
          }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.count).to eq(5)
          # TODO: test more data
        end
      end

      response 401, 'Invalid credentials' do
        let(:Authorization) { 'Bearer faketoken' }
        run_test!
      end
    end
  end

end
