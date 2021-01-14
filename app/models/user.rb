# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  admin_level        :string
#  current_sign_in_at :datetime
#  current_sign_in_ip :inet
#  encrypted_password :string           default(""), not null
#  is_root            :boolean          default(FALSE), not null
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :inet
#  name               :string           not null
#  sign_in_count      :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class User < ApplicationRecord

  # ---------------------------------------------------------------------------
  # MODULES
  # ---------------------------------------------------------------------------

  devise :database_authenticatable
  devise :trackable
  devise :omniauthable, omniauth_providers: %i[discord]

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :discord_users
  has_many :players

  has_many :recurring_tournament_contacts,
           inverse_of: :user,
           dependent: :destroy
  has_many :administrated_recurring_tournaments,
           through: :recurring_tournament_contacts,
           source: :recurring_tournament

  has_many :team_admins,
           inverse_of: :user,
           dependent: :destroy
  has_many :administrated_teams,
           through: :team_admins,
           source: :team

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :name, presence: true
  validates :admin_level,
            inclusion: {
              in: Ability::ADMIN_LEVELS,
              allow_nil: true
            }

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  pg_search_scope :by_keyword,
                  against: [:name],
                  using: {
                    tsearch: { prefix: true }
                  }

  def self.not_root
    where(is_root: false)
  end

  def self.lambda
    not_root.where(admin_level: nil)
  end

  def self.helps
    not_root.where(admin_level: Ability::ADMIN_LEVEL_HELP)
  end

  def self.admins
    not_root.where(admin_level: Ability::ADMIN_LEVEL_ADMIN)
  end

  def self.roots
    where(is_root: true)
  end

  def self.by_discord_id(discord_id)
    joins(:discord_users).where(discord_users: { discord_id: discord_id })
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.from_discord_omniauth(auth)
    puts "User#from_omniauth(#{auth.inspect})"

    # make sure auth comes from Discord
    return false unless auth.provider.to_sym == :discord

    # find & update DiscordUser
    discord_user = DiscordUser.where(discord_id: auth.uid).first_or_initialize
    discord_user.attributes = {
      username: auth.extra.raw_info.username,
      discriminator: auth.extra.raw_info.discriminator,
      avatar: auth.extra.raw_info.avatar
    }
    discord_user.save!

    # find & return User
    discord_user.return_or_create_user!
  end

  def admin_level=(v)
    super v.presence
  end

  def is_admin?
    !admin_level.nil?
  end

end
