# == Schema Information
#
# Table name: communities
#
#  id         :bigint           not null, primary key
#  address    :string           not null
#  latitude   :float            not null
#  longitude  :float            not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Community, type: :model do

  before(:each) do
    @existing_community = FactoryBot.create(:community)
    @new_community = FactoryBot.build(:community)
  end

  context 'is valid' do
    it 'creates the community' do
      expect(@new_community).to be_valid
    end
  end

  context 'is invalid' do
    it 'does not create a community without a name' do
      @new_community.name = ''
      expect(@new_community).to_not be_valid
    end

    it 'does not create a community without a address' do
      @new_community.address = ''
      expect(@new_community).to_not be_valid
    end

    it 'does not create a community without a latitude' do
      @new_community.latitude = nil
      expect(@new_community).to_not be_valid
    end

    it 'does not create a community without a longitude' do
      @new_community.longitude = nil
      expect(@new_community).to_not be_valid
    end
  end

end
