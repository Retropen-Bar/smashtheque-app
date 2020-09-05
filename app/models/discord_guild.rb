class DiscordGuild < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :related, polymorphic: true, optional: true

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :discord_id,
            presence: true,
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
