# == Schema Information
#
# Table name: users
#
#  id                            :bigint           not null, primary key
#  admin_level                   :string
#  coaching_details              :string
#  coaching_url                  :string
#  current_sign_in_at            :datetime
#  current_sign_in_ip            :inet
#  encrypted_password            :string           default(""), not null
#  graphic_designer_details      :string
#  is_available_graphic_designer :boolean          default(FALSE), not null
#  is_caster                     :boolean          default(FALSE), not null
#  is_coach                      :boolean          default(FALSE), not null
#  is_graphic_designer           :boolean          default(FALSE), not null
#  is_root                       :boolean          default(FALSE), not null
#  last_sign_in_at               :datetime
#  last_sign_in_ip               :inet
#  main_address                  :string
#  main_countrycode              :string           default(""), not null
#  main_latitude                 :float
#  main_locality                 :string
#  main_longitude                :float
#  name                          :string           not null
#  remember_created_at           :datetime
#  secondary_address             :string
#  secondary_countrycode         :string           default(""), not null
#  secondary_latitude            :float
#  secondary_locality            :string
#  secondary_longitude           :float
#  sign_in_count                 :integer          default(0), not null
#  twitter_username              :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
class User < ApplicationRecord
  # ---------------------------------------------------------------------------
  # MODULES
  # ---------------------------------------------------------------------------

  devise :database_authenticatable
  devise :trackable
  devise :omniauthable, omniauth_providers: %i[discord]
  devise :rememberable

  geocoded_by :main_address,
              latitude: :main_latitude,
              longitude: :main_longitude

  # ---------------------------------------------------------------------------
  # CONSTANTS
  # ---------------------------------------------------------------------------

  FRENCH_SPEAKING_COUNTRIES = [
    'FR', # France

    'GF', # Guyane
    'GP', # Guadeloupe
    'MQ', # Martinique
    'NC', # Nouvelle-Caledonie
    'PF', # Polynesie
    'RE', # Reunion
    'YT', # Mayotte

    'BE', # Belgique
    'CA', # Canada
    'CH', # Suisse
    'MA', # Maroc
    'MC'  # Monaco
  ].freeze

  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include HasName
  def self.on_abc_name
    :name
  end

  include HasTwitter

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_one :discord_user, dependent: :nullify
  has_one :player, dependent: :nullify

  has_many :smashgg_users,
           through: :player

  has_many :created_players,
           class_name: :Player,
           foreign_key: :creator_user_id

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

  has_many :community_admins,
           inverse_of: :user,
           dependent: :destroy
  has_many :administrated_communities,
           through: :community_admins,
           source: :community

  accepts_nested_attributes_for :player

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
  pg_search_scope :by_pg_search,
                  against: [:name],
                  using: {
                    tsearch: { prefix: true }
                  },
                  ignoring: :accents

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

  def self.without_discord_user
    where.not(
      id: DiscordUser.where.not(user_id: nil).select(:user_id)
    )
  end

  def self.without_player
    where.not(
      id: Player.where.not(user_id: nil).select(:user_id)
    )
  end

  def self.without_created_player
    where.not(
      id: Player.where.not(creator_user_id: nil).select(:creator_user_id)
    )
  end

  def self.without_administrated_recurring_tournament
    where.not(
      id: RecurringTournamentContact.where.not(user_id: nil).select(:user_id)
    )
  end

  def self.without_administrated_team
    where.not(
      id: TeamAdmin.where.not(user_id: nil).select(:user_id)
    )
  end

  def self.without_administrated_community
    where.not(
      id: CommunityAdmin.where.not(user_id: nil).select(:user_id)
    )
  end

  def self.without_any_link
    self.without_discord_user
        .without_player
        .without_created_player
        .without_administrated_recurring_tournament
        .without_administrated_team
        .without_administrated_community
  end

  def self.recurring_tournament_contacts
    where(id: RecurringTournamentContact.select(:user_id))
  end

  def self.by_contact_recurring_tournament_id(ids)
    where(id: RecurringTournamentContact.where(recurring_tournament_id: ids).select(:user_id))
  end

  def self.team_admins
    where(id: TeamAdmin.select(:user_id))
  end

  def self.community_admins
    where(id: CommunityAdmin.select(:user_id))
  end

  def self.casters
    where(is_caster: true)
  end

  def self.coaches
    where(is_coach: true)
  end

  def self.graphic_designers
    where(is_graphic_designer: true)
  end

  def self.by_name(name)
    where(name: name)
  end

  def self.by_name_like(name)
    where('unaccent(name) ILIKE unaccent(?)', name)
  end

  def self.by_name_contains_like(term)
    where('unaccent(name) ILIKE unaccent(?)', "%#{term}%")
  end

  def self.by_keyword(term)
    by_pg_search(term)
    # by_name_contains_like(term).or(
    #   where(id: by_pg_search(term).select(:id))
    # )
  end

  def self.with_main_address
    where.not(main_latitude: nil)
  end

  def self.with_secondary_address
    where.not(secondary_latitude: nil)
  end

  def self.with_address
    with_main_address.or(with_secondary_address)
  end

  def self.near_community(community, radius: 50)
    near(
      [community.latitude, community.longitude],
      radius,
      units: :km,
      select: 'id',
      select_distance: false,
      select_bearing: false
    ).except(
      :select
    )
  end

  def self.by_main_countrycode(countrycode)
    where(main_countrycode: countrycode)
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.from_discord_omniauth(auth)
    # make sure auth comes from Discord
    return false unless auth.provider.to_sym == :discord

    # find & update DiscordUser
    discord_user = DiscordUser.where(discord_id: auth.uid).first_or_initialize
    discord_user.attributes = {
      username: auth.extra.raw_info.username,
      discriminator: auth.extra.raw_info.discriminator,
      avatar: auth.extra.raw_info.avatar
    }
    discord_user.fetch_private_data auth.credentials.token
    discord_user.save!

    # find & return User
    discord_user.return_or_create_user!
  end

  def refetch_discord_user
    return true unless discord_user

    discord_user.fetch_discord_data
    return false unless discord_user.save

    discord_user.update_discord_roles
    true
  end

  def refetch_smashgg_users
    player&.refetch_smashgg_users
  end

  def refetch
    refetch_discord_user && refetch_smashgg_users
  end

  def admin_level=(val)
    super val.presence
  end

  def is_admin?
    !admin_level.nil?
  end

  # provides: @discord_user_id
  delegate :id,
           to: :discord_user,
           prefix: true,
           allow_nil: true

  # provides: @discord_id
  delegate :discord_id,
           to: :discord_user,
           allow_nil: true

  # provides: @discord_user_username
  delegate :username,
           to: :discord_user,
           prefix: true

  def discord_id=(discord_id)
    self.discord_user =
      if discord_id.blank?
        nil
      else
        DiscordUser.where(discord_id: discord_id).first_or_create!
      end
  end

  def potential_discord_user
    return nil unless discord_user.nil?

    DiscordUser.without_user.by_username_like(name).first
  end

  def _potential_discord_user
    @potential_discord_user ||= potential_discord_user
  end

  def addresses
    result = []
    if main_latitude
      result << {
        name: main_locality,
        latitude: main_latitude,
        longitude: main_longitude,
        countrycode: main_countrycode
      }
    end
    if secondary_latitude
      result << {
        name: secondary_locality,
        latitude: secondary_latitude,
        longitude: secondary_longitude,
        countrycode: secondary_countrycode
      }
    end
    result
  end

  def closest_main_community
    main_latitude && Community.near([main_latitude, main_longitude]).first
  end

  def closest_secondary_community
    secondary_latitude && Community.near([secondary_latitude, secondary_longitude]).first
  end

  def closest_communities
    [
      closest_main_community,
      closest_secondary_community
    ].compact.uniq
  end
end
