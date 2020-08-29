require 'swagger_helper'

describe 'Cities API', swagger_doc: 'v1/swagger.json' do

  before do
    @token = ApiToken.create!(name: 'City tests')
    @cities = FactoryBot.create_list(:city, 3)
    @valid_city_attributes = FactoryBot.attributes_for(:city)
  end

  path '/api/v1/cities' do

    get 'Fetches cities' do
      tags 'Cities'
      produces 'application/json'
      parameter name: :by_name_like,
                in: :query,
                type: :string,
                required: false,
                description: 'Search by similar name (ignoring case and accents)'

      response '200', 'cities found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        schema '$ref' => '#/components/schemas/cities_array'

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

    post 'Creates a city' do
      tags 'Cities'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :city_json, in: :body, schema: {
        type: :object,
        properties: {
          city: {
            '$ref' => '#/components/schemas/city_payload'
          }
        }
      }

      response 201, 'City created' do
        let(:Authorization) { "Bearer #{@token.token}" }
        schema '$ref' => '#/components/schemas/city'

        context 'Acceptable attributes' do
          let(:city_json) do
            {
              city: @valid_city_attributes
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body).deep_symbolize_keys
            expect(data[:name]).to eq(@valid_city_attributes[:name])
            expect(data[:icon]).to eq(@valid_city_attributes[:icon])

            expect(City.count).to eq(4)

            city = City.find(data[:id])
            target = JSON.parse(city.to_json).deep_symbolize_keys
            expect(data).to include(target)
          end
        end
      end

      response 422, 'unprocessable entity' do

        context 'Missing attributes' do
          let(:Authorization) { "Bearer #{@token.token}" }
          let(:city_json) do
            {
              city: @valid_city_attributes.merge(
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

        context 'Name already taken' do
          let(:Authorization) { "Bearer #{@token.token}" }
          let(:city_json) do
            {
              city: @valid_city_attributes.merge(
                name: City.last.name
              )
            }
          end
          schema '$ref' => '#/components/schemas/errors_object'

          run_test! do |response|
            data = JSON.parse(response.body).deep_symbolize_keys
            expect(data[:errors]).to have_key(:name)
            expect(data[:errors][:name]).to eq(['not_unique'])
          end
        end

      end
    end

  end

end
