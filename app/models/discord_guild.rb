# == Schema Information
#
# Table name: discord_guilds
#
#  id               :bigint           not null, primary key
#  icon             :string
#  invitation_url   :string
#  name             :string
#  splash           :string
#  twitter_username :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  discord_id       :string
#
class DiscordGuild < ApplicationRecord
  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include HasTwitter

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :discord_guild_admins,
           inverse_of: :discord_guild,
           dependent: :destroy
  has_many :admins,
           through: :discord_guild_admins,
           source: :discord_user

  has_many :discord_guild_relateds,
           inverse_of: :discord_guild,
           dependent: :destroy

  has_many :recurring_tournaments,
           inverse_of: :discord_guild,
           dependent: :nullify

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :discord_id,
            uniqueness: {
              allow_blank: true
            }

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_create_commit :fetch_discord_data_later
  def fetch_discord_data_later
    FetchDiscordGuildDataJob.perform_later(self)
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  scope :by_discord_id, -> v { where(discord_id: v) }

  def self.known
    where.not(icon: nil)
  end

  def self.unknown
    where(icon: nil)
  end

  def self.by_related_type(v)
    where(id: DiscordGuildRelated.by_related_type(v).select(:discord_guild_id))
  end

  def self.by_related_id(v)
    where(id: DiscordGuildRelated.by_related_id(v).select(:discord_guild_id))
  end

  def self.related_to_community
    by_related_type(:Community)
  end

  def self.related_to_team
    by_related_type(:Team)
  end

  def self.related_to_player
    by_related_type(:Player)
  end

  def self.related_to_character
    by_related_type(:Character)
  end

  def self.for_recurring_tournament
    where(id: RecurringTournament.select(:discord_guild_id))
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def relateds
    discord_guild_relateds.map(&:related)
  end

  def related_gids
    self.discord_guild_relateds.map(&:related_gid)
  end

  def related_gids=(gids)
    self.discord_guild_relateds = gids.map(&:presence).compact.map do |gid|
      self.discord_guild_relateds.build(related_gid: gid)
    end
  end

  def needs_fetching?
    return true if icon.blank?
    uri = URI(decorate.icon_image_url(32))
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    request = Net::HTTP::Head.new(uri)
    response = https.request(request)
    return !response.kind_of?(Net::HTTPSuccess)
  end

  def fetch_discord_data
    client = DiscordClient.new

    if invitation_url.blank?
      unless discord_id.blank?
        data = client.get_guild discord_id
        if data.has_key?('name')
          self.attributes = {
            name: data['name'],
            icon: data['icon'],
            splash: data['splash']
          }
        end
      end
    else
      data = client.get_guild_from_invitation(invitation_url)
      if data.has_key?('guild') && data['guild'].has_key?('name')
        self.attributes = {
          discord_id: data['guild']['id'],
          name: data['guild']['name'],
          icon: data['guild']['icon'],
          splash: data['guild']['splash']
        }
      end
    end
  end

  def self.fetch_unknown
    Rails.logger.info "[DiscordGuild] fetch_unknown"
    unknown.find_each do |discord_guild|
      Rails.logger.debug "Guild ##{discord_guild.id} is unknown"
      discord_guild.fetch_discord_data
      discord_guild.save!
      # we need to wait a bit between each request,
      # otherwise Discord returns empty results
      sleep 1
    end
  end

  def self.fetch_broken
    Rails.logger.info "[DiscordGuild] fetch_broken"
    find_each do |discord_guild|
      if discord_guild.needs_fetching?
        Rails.logger.debug "Guild ##{discord_guild.id} needs fetching"
        discord_guild.fetch_discord_data
        discord_guild.save
        # we need to wait a bit between each request,
        # otherwise Discord returns empty results
        sleep 1
      end
    end
  end

  def is_known?
    !!icon
  end

  def as_json(options = nil)
    result = super(options || {})
    result[:relateds] = discord_guild_relateds.map do |discord_guild_related|
      discord_guild_related.as_json
    end
    result
  end

  def self.from_data(invitation_url:)
    client = DiscordClient.new
    data = client.get_guild_from_invitation(invitation_url)
    return nil unless data.key?('guild') && data['guild'].key?('id')

    where(discord_id: data['guild']['id']).first_or_create!(invitation_url: invitation_url)
  end
end
