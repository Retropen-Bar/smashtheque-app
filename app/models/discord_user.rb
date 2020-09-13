# == Schema Information
#
# Table name: discord_users
#
#  id               :bigint           not null, primary key
#  avatar           :string
#  discriminator    :string
#  refresh_token    :string
#  token            :string
#  token_expires    :boolean
#  token_expires_at :integer
#  username         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  discord_id       :string
#
# Indexes
#
#  index_discord_users_on_discord_id  (discord_id) UNIQUE
#
class DiscordUser < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_one :admin_user, dependent: :nullify
  has_one :player, dependent: :nullify

  has_many :discord_guild_admins,
           inverse_of: :discord_user,
           dependent: :destroy
  has_many :administrated_discord_guilds,
           through: :discord_guild_admins,
           source: :discord_guild

  has_many :team_admins,
           inverse_of: :discord_user,
           dependent: :destroy
  has_many :administrated_teams,
           through: :team_admins,
           source: :team

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :discord_id, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_create_commit :fetch_discord_data_later
  def fetch_discord_data_later
    FetchDiscordUserDataJob.perform_later(self)
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  pg_search_scope :by_keyword,
                  against: [:discord_id, :username],
                  using: {
                    tsearch: { prefix: true }
                  }

  def self.with_admin_user
    where(id: AdminUser.select(:discord_user_id))
  end

  def self.known
    where.not(username: nil)
  end

  def self.unknown
    where(username: nil)
  end

  def self.team_admins
    where(id: TeamAdmin.select(:discord_user_id))
  end

  def self.on_abc(letter)
    letter == '$' ? on_abc_others : where("unaccent(username) ILIKE '#{letter}%'")
  end

  def self.on_abc_others
    result = self
    ('a'..'z').each do |letter|
      result = result.where.not("unaccent(username) ILIKE '#{letter}%'")
    end
    result
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def fetch_discord_data
    client = DiscordClient.new
    data = client.get_user discord_id
    self.attributes = {
      username: data['username'],
      discriminator: data['discriminator'],
      avatar: data['avatar']
    }
  end

  def self.fetch_unknown
    unknown.find_each do |discord_user|
      discord_user.fetch_discord_data
      discord_user.save!
      # we need to wait a bit between each request,
      # otherwise Discord return empty results
      sleep 1
    end
  end

  def is_admin?
    !!admin_user
  end

  def is_known?
    !!username
  end

end
