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
class DiscordUser < ApplicationRecord
  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include HasName
  def self.on_abc_name
    :username
  end

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :user, optional: true

  has_one :player, through: :user

  has_many :discord_guild_admins,
           inverse_of: :discord_user,
           dependent: :destroy
  has_many :administrated_discord_guilds,
           through: :discord_guild_admins,
           source: :discord_guild

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :discord_id, presence: true, uniqueness: true
  validates :user_id, uniqueness: { allow_nil: true }

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  before_validation :clean_discord_id
  def clean_discord_id
    self.discord_id.strip!
  end

  after_create_commit :fetch_discord_data_later
  def fetch_discord_data_later
    FetchDiscordUserDataJob.perform_later(self)
  end

  after_commit :update_user
  def update_user
    if !destroyed? && previous_changes.has_key?('username')
      old_username = previous_changes['username'].first
      new_username = previous_changes['username'].last
      if old_username.blank? && !new_username.blank? && user&.name&.starts_with?('#')
        user.update_attribute :name, new_username
      end
    end
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  pg_search_scope :by_pg_search,
                  against: [:discord_id, :username],
                  using: {
                    tsearch: { prefix: true }
                  },
                  ignoring: :accents

  def self.with_user
    where.not(user_id: nil)
  end

  def self.without_user
    where(user_id: nil)
  end

  def self.known
    where.not(username: nil)
  end

  def self.unknown
    where(username: nil)
  end

  def self.by_discriminated_username(discriminated_username)
    username, discriminator = discriminated_username.split('#')
    where(
      username: username,
      discriminator: discriminator
    )
  end

  def self.by_username(username)
    where(username: username)
  end

  def self.by_username_like(username)
    where('unaccent(username) ILIKE unaccent(?)', username)
  end

  def self.by_username_contains_like(term)
    where("unaccent(username) ILIKE unaccent(?)", "%#{term}%")
  end

  def self.by_keyword(term)
    by_pg_search(term)
    # by_username_contains_like(term).or(
    #   where(id: by_pg_search(term).select(:id))
    # )
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def discriminated_username
    [
      username,
      discriminator
    ].reject(&:blank?).join('#')
  end

  def return_or_create_user!
    if user.nil?
      fetch_discord_data if username.blank?
      self.user = User.create!(
        name: username || "##{discord_id}",
        twitter_username: twitter_username
      )
      save!
    end
    user
  end

  def needs_fetching?
    return true if avatar.blank?

    uri = URI(decorate.avatar_url(32))
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request = Net::HTTP::Head.new(uri)
    response = https.request(request)
    !response.is_a?(Net::HTTPSuccess)
  end

  def fetch_private_data(token)
    client = DiscordClient.new
    data = client.get_current_user_connections token
    data.each do |item|
      case item['type'].to_sym
      when :twitter
        self.twitter_username = item['name']
      when :twitch
        self.twitch_username = item['name']
      when :youtube
        self.youtube_username = item['name']
      end
    end
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

  def is_known?
    !!username
  end

  # provides: @player_id
  delegate :id,
           to: :player,
           prefix: true,
           allow_nil: true

  # provides: @user_is_admin?
  delegate :is_admin?,
           to: :user,
           prefix: true,
           allow_nil: true

  # provides @administrated_recurring_tournament_ids
  #          @administrated_recurring_tournaments
  #          @administrated_team_ids
  #          @administrated_teams
  delegate :administrated_recurring_tournament_ids,
           :administrated_recurring_tournaments,
           :administrated_team_ids,
           :administrated_teams,
           to: :user,
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

  def potential_user
    suggested_user&.first
  end

  def _potential_user
    @potential_user ||= potential_user
  end

  # returns nil or [user, reason]
  def suggested_user
    return nil unless user_id.nil?

    smashgg_user = SmashggUser.where(
      discord_discriminated_username: discriminated_username
    ).first
    if smashgg_user && smashgg_user.user
      return [smashgg_user.user, :smashgg_user]
    end

    user = User.without_discord_user.by_name_like(username).first
    if user
      return [user, :username]
    end

    nil
  end

  def update_discord_roles
    RetropenBotScheduler.update_member_roles(discord_id: discord_id)
  end
end
