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

  def is_admin?
    !!admin_user
  end

end
