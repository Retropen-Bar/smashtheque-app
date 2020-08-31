require 'rails_helper'

RSpec.describe Player, type: :model do

  before(:each) do
    @discord_creator = FactoryBot.create(:discord_user)
    @discord_user1 = FactoryBot.create(:discord_user)
    @discord_user2 = FactoryBot.create(:discord_user)
    @player1 = FactoryBot.create(:player, creator: @discord_creator, discord_user: @discord_user1)
    @new_player = FactoryBot.build(:player, creator: @discord_creator)
  end

  context 'is valid' do
    it 'creates the player' do
      expect(@new_player).to be_valid
    end
  end

  context 'is invalid' do
    it 'does not create a player without a name' do
      @new_player.name = ''
      expect(@new_player).to_not be_valid
    end

    it 'does not create a player without a creator' do
      @new_player.creator_id = nil
      expect(@new_player).to_not be_valid
    end

    it 'does not create a player with an already existing discord ID' do
      @new_player.discord_id = @player1.discord_id
      expect(@new_player).to_not be_valid
    end
  end

  context 'helpers' do
    it 'serializes to JSON' do
      json = JSON.parse(@player1.to_json).deep_symbolize_keys
      expect(json).to include(
        character_ids: @player1.characters_players.order(:position).map(&:character_id),
        character_names: @player1.character_names,
        characters: @player1.characters_players.order(:position).map(&:character).map do |c|
          {
            id: c.id,
            emoji: c.emoji,
            name: c.name
          }
        end,
        location: @player1.location.presence && {
          id: @player1.location.id,
          icon: @player1.location.icon,
          name: @player1.location.name
        },
        location_id: @player1.location_id,
        creator: {
          id: @player1.creator.id,
          discord_id: @player1.creator.discord_id
        },
        creator_discord_id: @player1.creator_discord_id,
        creator_id: @player1.creator_id,
        discord_id: @player1.discord_id,
        discord_user: @player1.discord_user.presence && {
          id: @player1.discord_user.id,
          discord_id: @player1.discord_user.discord_id
        },
        discord_user_id: @player1.discord_user_id,
        id: @player1.id,
        is_accepted: @player1.is_accepted,
        name: @player1.name,
        team: @player1.team.presence && {
          id: @player1.team.id,
          name: @player1.team.name
        },
        team_id: @player1.team_id
      )
    end
  end

end
