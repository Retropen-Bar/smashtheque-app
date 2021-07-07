# == Schema Information
#
# Table name: users
#
#  id                            :bigint           not null, primary key
#  admin_level                   :string
#  coaching_details              :string
#  coaching_url                  :string
#  current_sign_in_at            :datetime
#  current_sign_in_ip            :inet
#  encrypted_password            :string           default(""), not null
#  graphic_designer_details      :string
#  is_available_graphic_designer :boolean          default(FALSE), not null
#  is_caster                     :boolean          default(FALSE), not null
#  is_coach                      :boolean          default(FALSE), not null
#  is_graphic_designer           :boolean          default(FALSE), not null
#  is_root                       :boolean          default(FALSE), not null
#  last_sign_in_at               :datetime
#  last_sign_in_ip               :inet
#  main_address                  :string
#  main_countrycode              :string           default(""), not null
#  main_latitude                 :float
#  main_locality                 :string
#  main_longitude                :float
#  name                          :string           not null
#  remember_created_at           :datetime
#  secondary_address             :string
#  secondary_countrycode         :string           default(""), not null
#  secondary_latitude            :float
#  secondary_locality            :string
#  secondary_longitude           :float
#  sign_in_count                 :integer          default(0), not null
#  twitter_username              :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
require 'rails_helper'

RSpec.describe User, type: :model do

  before(:each) do
    @existing_user = FactoryBot.create(
      :user,
      discord_user: FactoryBot.create(:discord_user),
      admin_level: Ability::ADMIN_LEVEL_ADMIN
    )
    @other_discord_user = FactoryBot.create(:discord_user)
    @new_user = FactoryBot.build(
      :user,
      discord_user: @other_discord_user,
      admin_level: Ability::ADMIN_LEVEL_ADMIN
    )
  end

  context 'is valid' do
    it 'creates the user' do
      expect(@new_user).to be_valid
    end

    it 'creates an user without a level' do
      @new_user.admin_level = nil
      expect(@new_user).to be_valid
    end

    it 'creates a user without a discord user' do
      @new_user.discord_user = nil
      expect(@new_user).to be_valid
    end
  end

  context 'is invalid' do
    it 'does not create a user with an invalid level' do
      @new_user.admin_level = 'hello'
      expect(@new_user).to_not be_valid
    end
  end

end
