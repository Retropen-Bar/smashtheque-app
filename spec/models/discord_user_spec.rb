# == Schema Information
#
# Table name: discord_users
#
#  id               :bigint           not null, primary key
#  avatar           :string
#  discriminator    :string
#  twitch_username  :string
#  twitter_username :string
#  username         :string
#  youtube_username :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  discord_id       :string
#  user_id          :bigint
#
# Indexes
#
#  index_discord_users_on_discord_id  (discord_id) UNIQUE
#  index_discord_users_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe DiscordUser, type: :model do

  before(:each) do
    @creator = FactoryBot.create(:user)
    @discord_user = FactoryBot.create(:discord_user)
    @user = @discord_user.return_or_create_user!
    @player = FactoryBot.create(
      :player,
      creator_user: @creator,
      user: @user
    )
  end

  context 'helpers' do
    it 'serializes to JSON' do
      json = JSON.parse(@discord_user.to_json).deep_symbolize_keys
      expect(json).to include(
        administrated_discord_guilds: (
          @discord_user.administrated_discord_guilds.map do |g|
            {
              id: g.id,
              discord_id: g.discord_id,
              icon: g.icon,
              name: g.name
            }
          end
        ),
        administrated_recurring_tournaments: (
          @discord_user.administrated_recurring_tournaments.map do |t|
            {
              id: t.id,
              name: t.name
            }
          end
        ),
        administrated_teams: (
          @discord_user.administrated_teams.map do |t|
            {
              id: t.id,
              short_name: t.short_name,
              name: t.name
            }
          end
        ),
        avatar: @discord_user.avatar,
        discriminator:  @discord_user.discriminator,
        discord_id: @discord_user.discord_id,
        id: @discord_user.id,
        user_id: @discord_user.user_id,
        username: @discord_user.username
      )
    end
  end

end
