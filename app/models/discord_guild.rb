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

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    RetropenBotScheduler.rebuild_discord_guilds_chars_list
  end

  def twitter_username=(v)
    super (v || '').gsub('https://', '')
                   .gsub('http://', '')
                   .gsub('twitter.com/', '')
                   .gsub('@', '')
                   .strip
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

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
    without_discord do
      unknown.find_each do |discord_guild|
        Rails.logger.debug "Guild ##{discord_guild.id} is unknown"
        discord_guild.fetch_discord_data
        discord_guild.save!
        # we need to wait a bit between each request,
        # otherwise Discord returns empty results
        sleep 1
      end
    end
    last.update_discord unless ENV['NO_DISCORD']
  end

  def self.fetch_broken
    Rails.logger.info "[DiscordGuild] fetch_broken"
    without_discord do
      find_each do |discord_guild|
        if discord_guild.needs_fetching?
          Rails.logger.debug "Guild ##{discord_guild.id} needs fetching"
          discord_guild.fetch_discord_data
          discord_guild.save!
          # we need to wait a bit between each request,
          # otherwise Discord returns empty results
          sleep 1
        end
      end
    end
    last.update_discord unless ENV['NO_DISCORD']
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

end
