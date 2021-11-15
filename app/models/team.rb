# == Schema Information
#
# Table name: teams
#
#  id                 :bigint           not null, primary key
#  creation_year      :integer
#  description        :text
#  is_offline         :boolean
#  is_online          :boolean
#  is_recruiting      :boolean
#  is_sponsor         :boolean
#  name               :string
#  recruiting_details :text
#  short_name         :string
#  twitter_username   :string
#  website_url        :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class Team < ApplicationRecord
  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include HasLogo

  include HasName
  def self.on_abc_name
    :name
  end

  include HasTwitter

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :players_teams, dependent: :destroy
  has_many :players, through: :players_teams

  has_many :discord_guild_relateds, as: :related, dependent: :destroy
  has_many :discord_guilds, through: :discord_guild_relateds

  has_many :you_tube_channels, as: :related, dependent: :nullify

  has_many :twitch_channels, as: :related, dependent: :nullify

  has_many :team_admins,
           inverse_of: :team,
           dependent: :destroy
  has_many :admins,
           through: :team_admins,
           source: :user

  has_one_attached :roster

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :short_name, presence: true
  validates :name, presence: true
  validates :roster, content_type: /\Aimage\/.*\z/

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.by_short_name_like(short_name)
    where('short_name ILIKE ?', short_name)
  end

  def self.administrated_by(user_id)
    where(id: TeamAdmin.where(user_id: user_id).select(:team_id))
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def first_discord_guild
    discord_guilds.first
  end

  def admin_discord_ids
    admins.map(&:discord_id)
  end

  def roster_url
    return nil unless roster.attached?

    roster.service_url
  end

  def roster_url=(url)
    return if url.blank?

    uri = URI.parse(url)
    roster.attach(io: Down.download(url), filename: File.basename(uri.path))
  end

  def as_json(options = {})
    super(options.merge(
      include: {
        admins: {
          only: %i(discord_id avatar discriminator username)
        },
        discord_guilds: {
          only: %i(id discord_id icon name)
        },
        players: {
          only: %i(id name)
        }
      },
      methods: %i(
        logo_url
        roster_url
        admin_discord_ids
        discord_guild_ids
        player_ids
      )
    ))
  end

  # ---------------------------------------------------------------------------
  # global search
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i(name short_name)

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
