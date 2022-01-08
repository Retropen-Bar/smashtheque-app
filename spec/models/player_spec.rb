# == Schema Information
#
# Table name: players
#
#  id              :bigint           not null, primary key
#  ban_details     :text
#  character_names :text             default([]), is an Array
#  is_accepted     :boolean
#  is_banned       :boolean          default(FALSE), not null
#  name            :string
#  old_names       :string           default([]), is an Array
#  team_names      :text             default([]), is an Array
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_user_id :integer          not null
#  user_id         :integer
#
# Indexes
#
#  index_players_on_creator_user_id  (creator_user_id)
#  index_players_on_user_id          (user_id)
#
# Foreign Keys
#
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

  context 'discord_id=' do
    context 'with a User' do
      context 'giving an unknown Discord ID' do
        it 'creates and links a DiscordUser to the existing User' do
          user = FactoryBot.create(:user)
          player = FactoryBot.create(:player, creator_user: @creator, user: user)
          discord_id = FactoryBot.attributes_for(:discord_user)[:discord_id]

          expect(user.discord_user).to be_nil

          expect do
            player.discord_id = discord_id
            player.save
          end.to change { DiscordUser.count }.by(1)
          player.reload

          expect(DiscordUser.last.discord_id).to eq(discord_id)
          expect(player.user).to eq(user)
        end
      end
      context 'giving a known Discord ID without a User' do
        it 'links the DiscordUser to the existing User' do
          user = FactoryBot.create(:user)
          player = FactoryBot.create(:player, creator_user: @creator, user: user)
          discord_user = FactoryBot.create(:discord_user)
          users_count = User.count
          discord_users_count = DiscordUser.count

          expect(user.discord_user).to be_nil

          player.discord_id = discord_user.discord_id
          player.save
          player.reload

          expect(User.count).to eq(users_count)
          expect(DiscordUser.count).to eq(discord_users_count)
          expect(player.user).to eq(user)
          expect(player.user.discord_user).to eq(discord_user)
        end
      end
      context 'giving a known Discord ID linked to a User' do
        it 'links the DiscordUser to the existing User and unlinks the other User' do
          user = FactoryBot.create(:user)
          player = FactoryBot.create(:player, creator_user: @creator, user: user)
          other_discord_user = FactoryBot.create(:discord_user)
          other_user = other_discord_user.return_or_create_user!
          users_count = User.count
          discord_users_count = DiscordUser.count

          expect(user.discord_user).to be_nil

          player.discord_id = other_discord_user.discord_id
          player.save
          player.reload
          other_user.reload

          expect(User.count).to eq(users_count)
          expect(DiscordUser.count).to eq(discord_users_count)
          expect(player.user).to eq(user) # keeps the same user
          expect(player.user.discord_user).to eq(other_discord_user) # but links
          expect(other_user.discord_user).to be_nil
        end
      end
      context 'giving nil' do
        it 'unlinks the DiscordUser' do
          discord_user = FactoryBot.create(:discord_user)
          user = discord_user.return_or_create_user!
          player = FactoryBot.create(:player, creator_user: @creator, user: user)
          users_count = User.count
          discord_users_count = DiscordUser.count

          expect(player.user.discord_user).to eq(discord_user)

          player.discord_id = nil
          player.save
          player.reload

          expect(User.count).to eq(users_count)
          expect(DiscordUser.count).to eq(discord_users_count)
          expect(player.user).to eq(user) # keeps the same user
          expect(player.user.discord_user).to be_nil # but unlinks
        end
      end
    end
    context 'without a user' do
      context 'giving an unknown Discord ID' do
        it 'creates and links a User with a DiscordUser' do
          player = FactoryBot.create(:player, creator_user: @creator)
          expect(player.user).to be_nil
          discord_id = FactoryBot.attributes_for(:discord_user)[:discord_id]
          users_count = User.count
          discord_users_count = DiscordUser.count

          player.discord_id = discord_id
          player.save
          player.reload

          expect(User.count).to eq(users_count + 1)
          expect(player.user).to eq(User.last)
          expect(DiscordUser.count).to eq(discord_users_count + 1)
          expect(player.user.discord_user).to eq(DiscordUser.last)
          expect(DiscordUser.last.discord_id).to eq(discord_id)
        end
      end
      context 'giving a known Discord ID without a User' do
        it 'creates a User and links the DiscordUser to it' do
          player = FactoryBot.create(:player, creator_user: @creator)
          discord_user = FactoryBot.create(:discord_user)
          users_count = User.count
          discord_users_count = DiscordUser.count

          expect(player.user).to be_nil
          expect(discord_user.user).to be_nil

          player.discord_id = discord_user.discord_id
          player.save
          player.reload

          expect(User.count).to eq(users_count + 1)
          expect(player.user).to eq(User.last)
          expect(DiscordUser.count).to eq(discord_users_count)
          expect(player.user.discord_user).to eq(discord_user)
        end
      end
      context 'giving a known Discord ID linked to a User' do
        context 'if the existing User has no player' do
          it 'links the existing User' do
            player = FactoryBot.create(:player, creator_user: @creator)
            discord_user = FactoryBot.create(:discord_user)
            user = discord_user.return_or_create_user!
            users_count = User.count
            discord_users_count = DiscordUser.count

            expect(player.user).to be_nil
            expect(user.player).to be_nil

            player.discord_id = discord_user.discord_id
            player.save
            player.reload

            expect(User.count).to eq(users_count)
            expect(DiscordUser.count).to eq(discord_users_count)
            expect(player.user).to eq(user) # links the existing user
            expect(player.user.discord_user).to eq(discord_user) # and it is still linked to the Discord User
          end
        end
        context 'if the existing User has its own other Player' do
          it 'refuses to link the existing User' do
            player = FactoryBot.create(:player, creator_user: @creator)
            discord_user = FactoryBot.create(:discord_user)
            user = discord_user.return_or_create_user!
            other_player = FactoryBot.create(:player, creator_user: @creator, user: user)
            users_count = User.count
            discord_users_count = DiscordUser.count

            expect(player.user).to be_nil

            player.discord_id = discord_user.discord_id
            expect(player).to_not be_valid
            expect(player.save).to be_falsy
            player.reload

            expect(User.count).to eq(users_count)
            expect(DiscordUser.count).to eq(discord_users_count)
            expect(user.player).to eq(other_player) # keeps the existing link
          end
        end
      end
      context 'giving nil' do
        it 'does nothing' do
          player = FactoryBot.create(:player, creator_user: @creator)
          users_count = User.count

          expect(player.user).to be_nil

          player.discord_id = nil
          player.save
          player.reload

          expect(User.count).to eq(users_count)
          expect(player.user).to be_nil # still no user
        end
      end
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
