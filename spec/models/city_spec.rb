require 'rails_helper'

RSpec.describe City, type: :model do

  before(:each) do
    @existing_city = City.create!(name: 'Paris')
    @new_city = FactoryBot.build(:city)
  end

  context 'is valid' do
    it 'creates the city' do
      expect(@new_city).to be_valid
    end
  end

  context 'is invalid' do
    it 'does not create a city without a name' do
      @new_city.name = ''
      expect(@new_city).to_not be_valid
    end

    it 'does not create a city with an already existing name' do
      @new_city.name = @existing_city.name
      expect(@new_city).to_not be_valid
    end

    it 'does not create a city with a name similar to an existing name' do
      @new_city.name = 'pàris'
      expect(@new_city).to_not be_valid
    end
  end

end
