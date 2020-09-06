class DiscordGuild < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :related, polymorphic: true, optional: true

  has_many :discord_guild_admins,
           inverse_of: :discord_guild,
           dependent: :destroy
  has_many :admins,
           through: :discord_guild_admins,
           source: :discord_user

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :discord_id,
            uniqueness: {
              allow_nil: true
            }

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
    where(related_type: v)
  end

  def self.by_related_id(v)
    where(related_id: v)
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def related_gid
    self.related&.to_global_id&.to_s
  end

  def related_gid=(gid)
    self.related = GlobalID::Locator.locate gid
  end

  def fetch_discord_data
    client = DiscordClient.new
    data = client.get_guild discord_id
    # TODO: check here if we got a proper response or an access error
    self.attributes = {
      name: data['name'],
      icon: data['icon'],
      splash: data['splash']
    }
  end

  def self.fetch_unknown
    unknown.find_each do |discord_guild|
      discord_guild.fetch_discord_data
      discord_guild.save!
      # we need to wait a bit between each request,
      # otherwise Discord return empty results
      sleep 1
    end
  end

  def is_known?
    !!icon
  end

end
