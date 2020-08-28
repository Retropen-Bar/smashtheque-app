require 'swagger_helper'

describe 'Teams API', swagger_doc: 'v1/swagger.json' do

  before do
    @token = ApiToken.create!(name: 'Team tests')
    @teams = FactoryBot.create_list(:team, 5)
  end

  path '/api/v1/teams' do

    get 'Fetches teams' do
      tags 'Teams'
      produces 'application/json'
      parameter name: :by_short_name_like,
                in: :query,
                type: :string,
                required: false,
                description: 'Search by similar short_name (ignoring case)'

      response 200, 'teams found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        schema '$ref' => '#/components/schemas/teams_array'

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
