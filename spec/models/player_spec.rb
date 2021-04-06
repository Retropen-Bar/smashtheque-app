# == Schema Information
#
# Table name: players
#
#  id                              :bigint           not null, primary key
#  ban_details                     :text
#  best_reward_level1              :string
#  best_reward_level2              :string
#  character_names                 :text             default([]), is an Array
#  is_accepted                     :boolean
#  is_banned                       :boolean          default(FALSE), not null
#  name                            :string
#  old_names                       :string           default([]), is an Array
#  points                          :integer          default(0), not null
#  points_in_2019                  :integer          default(0), not null
#  points_in_2020                  :integer          default(0), not null
#  points_in_2021                  :integer          default(0), not null
#  rank                            :integer
#  rank_in_2019                    :integer
#  rank_in_2020                    :integer
#  rank_in_2021                    :integer
#  team_names                      :text             default([]), is an Array
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  best_player_reward_condition_id :bigint
#  creator_user_id                 :integer          not null
#  user_id                         :integer
#
# Indexes
#
#  index_players_on_best_player_reward_condition_id  (best_player_reward_condition_id)
#  index_players_on_creator_user_id                  (creator_user_id)
#  index_players_on_user_id                          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (best_player_reward_condition_id => player_reward_conditions.id)
#  fk_rails_...  (creator_user_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Player, type: :model do

  before(:each) do
    @discord_creator = FactoryBot.create(:discord_user)
    @creator = @discord_creator.return_or_create_user!
    @discord_user1 = FactoryBot.create(:discord_user)
    @user1 = @discord_user1.return_or_create_user!
    @discord_user2 = FactoryBot.create(:discord_user)
    @user2 = @discord_user2.return_or_create_user!
    @player1 = FactoryBot.create(
      :player,
      creator_user: @creator,
      user: @user1
    )
    @new_player = FactoryBot.build(
      :player,
      creator_user: @creator
    )
    @characters = FactoryBot.create_list(:character, 5)
    @invalid_player = FactoryBot.build(:player)
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
      @new_player.creator_user_id = nil
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
        creator_user: {
          id: @player1.creator_user.id,
          name: @player1.creator_user.name
        },
        creator_discord_id: @player1.creator_discord_id,
        creator_user_id: @player1.creator_user_id,
        discord_id: @player1.discord_id,
        discord_user: @player1.discord_user.presence && {
          id: @player1.discord_user.id,
          discord_id: @player1.discord_user.discord_id
        },
        discord_user_id: @player1.discord_user_id,
        id: @player1.id,
        is_accepted: @player1.is_accepted,
        name: @player1.name,
        team_ids: @player1.players_teams.order(:position).map(&:team_id),
        team_names: @player1.team_names,
        teams: @player1.players_teams.order(:position).map(&:team).map do |t|
          {
            id: t.id,
            short_name: t.short_name,
            name: t.name
          }
        end
      )
    end
  end

  context 'character_ids=' do
    it 'creates with positions' do
      character_ids = @characters.map(&:id)
      player = FactoryBot.build(:player,
        creator_user: @creator,
        character_ids: character_ids
      )
      player.save!

      # make sure those CharactersPlayer have been created and linked properly
      created_characters_players = CharactersPlayer.order(:position).last(@characters.count)
      expect(created_characters_players.pluck(:player_id)).to eq([player.id]*@characters.count)
      expect(created_characters_players.pluck(:character_id)).to eq(character_ids)
      expect(created_characters_players.pluck(:position)).to eq((0..@characters.count-1).to_a)
    end

    it 'updates with positions' do
      # make sure this player didn't already have any characters
      expect(CharactersPlayer.where(player: @player1).count).to eq(0)

      character_ids = @characters.map(&:id)
      @player1.character_ids = character_ids
      @player1.save!

      # make sure those CharactersPlayer have been created and linked properly
      created_characters_players = CharactersPlayer.order(:position).last(@characters.count)
      expect(created_characters_players.pluck(:player_id)).to eq([@player1.id]*@characters.count)
      expect(created_characters_players.pluck(:character_id)).to eq(character_ids)
      expect(created_characters_players.pluck(:position)).to eq((0..@characters.count-1).to_a)
    end

    it 'fills positions even on a new and invalid player' do
      # make sure @invalid_player is indeed invalid and new
      expect(@invalid_player).to_not be_valid
      expect(@invalid_player.persisted?).to be_falsy

      character_ids = @characters.map(&:id)
      @invalid_player.character_ids = character_ids

      positions = @invalid_player.characters_players.map(&:position)
      expect(positions).to eq((0..@characters.count-1).to_a)
    end

    it 'and allows to save afterwards' do
      # make sure @invalid_player is indeed invalid and new
      expect(@invalid_player).to_not be_valid
      expect(@invalid_player.persisted?).to be_falsy

      character_ids = @characters.map(&:id)
      @invalid_player.character_ids = character_ids

      # now we fix the invalidity
      @invalid_player.creator_user = @creator
      expect(@invalid_player).to be_valid
      @invalid_player.save!

      # make sure those CharactersPlayer have been created and linked properly
      created_characters_players = CharactersPlayer.order(:position).last(@characters.count)
      expect(created_characters_players.pluck(:player_id)).to eq([@invalid_player.id]*@characters.count)
      expect(created_characters_players.pluck(:character_id)).to eq(character_ids)
      expect(created_characters_players.pluck(:position)).to eq((0..@characters.count-1).to_a)
    end
  end

end
