class DiscordUser < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_one :admin_user, dependent: :nullify
  has_one :player, dependent: :nullify

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :discord_id, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.with_admin_user
    where(id: AdminUser.select(:discord_user_id))
  end

  def self.known
    where.not(username: nil)
  end

  def self.unknown
    where(username: nil)
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

end
