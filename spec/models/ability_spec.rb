require 'rails_helper'

RSpec.describe Ability, type: :model do

  before(:all) do
    @root = Ability.new(AdminUser.create!(
      discord_user: FactoryBot.create(:discord_user),
      level: Ability::LEVEL_ADMIN,
      is_root: true
    ))
    @admin = Ability.new(AdminUser.create!(
      discord_user: FactoryBot.create(:discord_user),
      level: Ability::LEVEL_ADMIN
    ))
    @help = Ability.new(AdminUser.create!(
      discord_user: FactoryBot.create(:discord_user),
      level: Ability::LEVEL_HELP
    ))
  end

  context 'root admins can' do
    it 'create API tokens' do
      expect(@root.can?(:create, ApiToken)).to be_truthy
    end
    it 'destroy API requests' do
      expect(@root.can?(:destroy, ApiRequest)).to be_truthy
    end
  end

  context 'admins cannot' do
    it 'create API tokens' do
      expect(@admin.can?(:create, ApiToken)).to be_falsy
    end
    it 'destroy API requests' do
      expect(@admin.can?(:destroy, ApiRequest)).to be_falsy
    end
    it 'update a root admin' do
      expect(@admin.can?(:update, @root.user)).to be_falsy
    end
    it 'destroy a root admin' do
      expect(@admin.can?(:destroy, @root.user)).to be_falsy
    end
  end

  context 'admins can' do
    it 'read a root admin' do
      expect(@admin.can?(:read, @root.user)).to be_truthy
    end
    it 'read admins' do
      expect(@admin.can?(:read, AdminUser)).to be_truthy
    end
    it 'create admins' do
      expect(@admin.can?(:create, AdminUser)).to be_truthy
    end
    it 'update admins' do
      expect(@admin.can?(:update, AdminUser)).to be_truthy
    end
    it 'destroy admins' do
      expect(@admin.can?(:destroy, AdminUser)).to be_truthy
    end
    it 'destroy a player' do
      expect(@admin.can?(:destroy, Player)).to be_truthy
    end
    it 'destroy a City' do
      expect(@admin.can?(:destroy, Locations::City)).to be_truthy
    end
  end

  context 'helps cannot' do
    it 'create admins' do
      expect(@help.can?(:create, AdminUser)).to be_falsy
    end
    it 'update admins' do
      expect(@help.can?(:update, AdminUser)).to be_falsy
    end
    it 'destroy admins' do
      expect(@help.can?(:destroy, AdminUser)).to be_falsy
    end
    it 'destroy a player' do
      expect(@help.can?(:destroy, Player)).to be_falsy
    end
    it 'destroy a City' do
      expect(@help.can?(:destroy, Locations::City)).to be_falsy
    end
  end

  context 'helps can' do
    it 'create a City' do
      expect(@help.can?(:create, Locations::City)).to be_truthy
    end
    it 'read a Player' do
      expect(@help.can?(:read, Player)).to be_truthy
    end
    it 'create a Player' do
      expect(@help.can?(:create, Player)).to be_truthy
    end
    it 'accept a Player' do
      expect(@help.can?(:accept, Player)).to be_truthy
    end
    it 'create a Team' do
      expect(@help.can?(:create, Team)).to be_truthy
    end
  end

end
