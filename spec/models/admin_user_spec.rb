require 'rails_helper'

RSpec.describe AdminUser, type: :model do

  before(:each) do
    @existing_admin_user = AdminUser.create!(
      discord_user: FactoryBot.create(:discord_user),
      level: Ability::LEVEL_ADMIN
    )
    @other_discord_user = FactoryBot.create(:discord_user)
    @new_admin_user = AdminUser.new(
      discord_user: @other_discord_user,
      level: Ability::LEVEL_ADMIN
    )
  end

  context 'is valid' do
    it 'creates the admin' do
      expect(@new_admin_user).to be_valid
    end
  end

  context 'is invalid' do
    it 'does not create an admin without a discord user' do
      @new_admin_user.discord_user = nil
      expect(@new_admin_user).to_not be_valid
    end

    it 'does not create an admin with an already taken discord user' do
      @new_admin_user.discord_user = @existing_admin_user.discord_user
      expect(@new_admin_user).to_not be_valid
    end

    it 'does not create an admin without a level' do
      @new_admin_user.level = nil
      expect(@new_admin_user).to_not be_valid
    end

    it 'does not create an admin with an invalid level' do
      @new_admin_user.level = 'hello'
      expect(@new_admin_user).to_not be_valid
    end
  end

end
