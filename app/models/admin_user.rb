# == Schema Information
#
# Table name: admin_users
#
#  id                 :bigint           not null, primary key
#  current_sign_in_at :datetime
#  current_sign_in_ip :inet
#  encrypted_password :string           default(""), not null
#  is_root            :boolean          default(FALSE), not null
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :inet
#  level              :string           not null
#  sign_in_count      :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discord_user_id    :bigint
#
# Indexes
#
#  index_admin_users_on_discord_user_id  (discord_user_id) UNIQUE
#
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
  validates :level, presence: true, inclusion: { in: Ability::LEVELS }

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.not_root
    where(is_root: false)
  end

  def self.helps
    not_root.where(level: Ability::LEVEL_HELP)
  end

  def self.admins
    not_root.where(level: Ability::LEVEL_ADMIN)
  end

  def self.roots
    where(is_root: true)
  end

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
