require 'swagger_helper'

describe 'Locations API', swagger_doc: 'v1/swagger.json' do

  before do
    @token = ApiToken.create!(name: 'Location tests')
    @locations = FactoryBot.create_list(:location, 3)
    @valid_location_attributes = FactoryBot.attributes_for(:location)
  end

  path '/api/v1/locations' do

    get 'Fetches locations' do
      tags 'Locations'
      produces 'application/json'
      parameter name: :by_name_like,
                in: :query,
                type: :string,
                required: false,
                description: 'Search by similar name (ignoring case and accents)'

      response '200', 'locations found' do
        let(:Authorization) { "Bearer #{@token.token}" }
        schema '$ref' => '#/components/schemas/locations_array'

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

    post 'Creates a location' do
      tags 'Locations'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :location_json, in: :body, schema: {
        type: :object,
        properties: {
          location: {
            '$ref' => '#/components/schemas/location_payload'
          }
        }
      }

      response 201, 'Location created' do
        let(:Authorization) { "Bearer #{@token.token}" }
        schema '$ref' => '#/components/schemas/location'

        context 'Acceptable attributes' do
          let(:location_json) do
            {
              location: @valid_location_attributes
            }
          end

          run_test! do |response|
            data = JSON.parse(response.body).deep_symbolize_keys
            expect(data[:name]).to eq(@valid_location_attributes[:name])
            expect(data[:icon]).to eq(@valid_location_attributes[:icon])

            expect(Location.count).to eq(4)

            location = Location.find(data[:id])
            target = JSON.parse(location.to_json).deep_symbolize_keys
            expect(data).to include(target)
          end
        end

        context 'Without type given' do
          let(:location_json) do
            {
              location: @valid_location_attributes.merge(type: nil)
            }
          end

          run_test!
        end
      end

      response 422, 'unprocessable entity' do

        context 'Missing attributes' do
          let(:Authorization) { "Bearer #{@token.token}" }
          let(:location_json) do
            {
              location: @valid_location_attributes.merge(
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
          let(:location_json) do
            {
              location: @valid_location_attributes.merge(
                name: Location.last.name
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
