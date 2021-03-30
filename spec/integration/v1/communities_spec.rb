require 'swagger_helper'

describe 'Communities API', swagger_doc: 'v1/swagger.json' do

  before do
    @token = ApiToken.create!(name: 'Community tests')
    @communities = FactoryBot.create_list(:community, 3)
    @valid_community_attributes = FactoryBot.attributes_for(:community)
  end

  path '/api/v1/communities' do

    get 'Fetches communities' do
      tags 'Communities'
      produces 'application/json'
      parameter name: :by_name_like,
                in: :query,
                type: :string,
                required: false,
                description: 'Search by similar name (ignoring case and accents)'

      response '200', 'communities found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        schema '$ref' => '#/components/schemas/communities_array'

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
