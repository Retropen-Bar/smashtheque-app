# == Schema Information
#
# Table name: discord_users
#
#  id            :bigint           not null, primary key
#  avatar        :string
#  discriminator :string
#  username      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  discord_id    :string
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

  has_many :recurring_tournament_contacts,
           inverse_of: :discord_user,
           dependent: :destroy
  has_many :administrated_recurring_tournaments,
           through: :recurring_tournament_contacts,
           source: :recurring_tournament

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

  def needs_fetching?
    return true if avatar.blank?
    uri = URI(decorate.avatar_url(32))
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request = Net::HTTP::Head.new(uri)
    response = https.request(request)
    return !response.kind_of?(Net::HTTPSuccess)
  end

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
    Rails.logger.info "[DiscordUser] fetch_unknown"
    unknown.find_each do |discord_user|
      Rails.logger.debug "User ##{discord_user.id} is unknown"
      discord_user.fetch_discord_data
      discord_user.save!
      # we need to wait a bit between each request,
      # otherwise Discord returns empty results
      sleep 1
    end
  end

  def self.fetch_broken
    Rails.logger.info "[DiscordUser] fetch_broken"
    find_each do |discord_user|
      if discord_user.needs_fetching?
        Rails.logger.debug "User ##{discord_user.id} needs fetching"
        discord_user.fetch_discord_data
        discord_user.save!
        # we need to wait a bit between each request,
        # otherwise Discord returns empty results
        sleep 1
      end
    end
  end

  def is_admin?
    !!admin_user
  end

  def is_known?
    !!username
  end

  delegate :id,
           to: :player,
           prefix: true,
           allow_nil: true

  def as_json(options = {})
    super(options.merge(
      include: {
        administrated_discord_guilds: {
          only: %i(id discord_id icon name)
        },
        administrated_recurring_tournaments: {
          only: %i(id name)
        },
        administrated_teams: {
          only: %i(id short_name name)
        }
      },
      methods: %i(
        player_id
        administrated_discord_guild_ids
        administrated_recurring_tournament_ids
        administrated_team_ids
      )
    ))
  end

end
