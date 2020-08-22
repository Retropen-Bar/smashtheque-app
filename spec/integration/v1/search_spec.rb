require 'swagger_helper'

describe 'Search API', swagger_doc: 'v1/swagger.json' do

  path '/api/v1/search' do

    get 'Searches globally' do
      tags 'Search'
      consumes 'application/json'
      security []
      # parameter name: :page, in: :query, type: :string

      response '200', 'results found' do
        run_test!
      end
    end
  end

end
