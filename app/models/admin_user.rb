class AdminUser < ApplicationRecord

  # ---------------------------------------------------------------------------
  # MODULES
  # ---------------------------------------------------------------------------

  devise :database_authenticatable
  devise :trackable
  devise :omniauthable, omniauth_providers: %i[discord]

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :discord_user

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :discord_user, uniqueness: true

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.from_discord_omniauth(auth)
    puts "User#from_omniauth(#{auth.inspect})"

    # make sure auth comes from Discord
    return false unless auth.provider.to_sym == :discord

    # find & update DiscordUser
    discord_user = DiscordUser.find_by(discord_id: auth.uid)
    return false if discord_user.nil?
    discord_user.attributes = {
      username: auth.extra.raw_info.username,
      discriminator: auth.extra.raw_info.discriminator,
      avatar: auth.extra.raw_info.avatar
    }
    discord_user.save!

    # find & return AdminUser
    discord_user.admin_user
  end

  delegate :discord_id,
           to: :discord_user

  delegate :username,
           to: :discord_user,
           prefix: true

end
