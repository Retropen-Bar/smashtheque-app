# == Schema Information
#
# Table name: teams
#
#  id               :bigint           not null, primary key
#  is_offline       :boolean
#  is_online        :boolean
#  is_sponsor       :boolean
#  name             :string
#  short_name       :string
#  twitter_username :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Team < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :players_teams, dependent: :destroy
  has_many :players, through: :players_teams
  has_many :discord_guild_relateds, as: :related, dependent: :nullify
  has_many :discord_guilds, through: :discord_guild_relateds

  has_many :team_admins,
           inverse_of: :team,
           dependent: :destroy
  has_many :admins,
           through: :team_admins,
           source: :user

  has_one_attached :logo
  has_one_attached :roster

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :short_name, presence: true
  validates :name, presence: true
  validates :logo, content_type: /\Aimage\/.*\z/
  validates :roster, content_type: /\Aimage\/.*\z/

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    # on create: previous_changes = {"id"=>[nil, <id>], "name"=>[nil, <name>], ...}
    # on update: previous_changes = {"name"=>["old_name", "new_name"], ...}
    # on delete: destroyed? = true and old attributes are available

    # in any case, both the teams list and the teams lineups must be updated
    RetropenBotScheduler.rebuild_teams
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.on_abc(letter)
    where("unaccent(name) ILIKE '#{letter}%'")
  end

  def self.by_short_name_like(short_name)
    where('short_name ILIKE ?', short_name)
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

  def logo_url
    return nil unless logo.attached?
    logo.service_url
  end

  def logo_url=(url)
    return false if url.blank?
    uri = URI.parse(url)
    open(url) do |f|
      logo.attach(io: File.open(f.path), filename: File.basename(uri.path))
    end
  end

  def roster_url
    return nil unless roster.attached?
    roster.service_url
  end

  def roster_url=(url)
    return false if url.blank?
    uri = URI.parse(url)
    open(url) do |f|
      roster.attach(io: File.open(f.path), filename: File.basename(uri.path))
    end
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
