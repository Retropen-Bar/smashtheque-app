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

  include HasTrackRecords

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :players_teams, dependent: :destroy
  has_many :players, through: :players_teams

  has_many :met_reward_conditions, through: :players
  has_many :reward_conditions, through: :met_reward_conditions
  has_many :rewards, through: :met_reward_conditions

  has_many :track_records, through: :players

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

  has_rich_text :description
  has_rich_text :recruiting_details

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

  scope :by_is_online, -> v { where(is_online: v) }
  scope :by_is_offline, -> v { where(is_offline: v) }
  scope :by_is_sponsor, -> v { where(is_sponsor: v) }

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
  # HasTrackRecords overrides
  # ---------------------------------------------------------------------------

  # def self.with_track_records(is_online:, year: nil)
  #   column_suffix = [
  #     is_online ? 'online' : 'offline',
  #     year ? "in_#{year}" : 'all_time'
  #   ].join('_')
  #   subquery = TrackRecord.by_tracked_type(self).by_is_online(is_online).on_year(year).select(
  #     :tracked_id,
  #     "points AS #{sanitize_sql("points_#{column_suffix}")}",
  #     "rank AS #{sanitize_sql("rank_#{column_suffix}")}"
  #   )
  #   joins(
  #     "LEFT OUTER JOIN (#{subquery.to_sql}) #{sanitize_sql("track_records_#{column_suffix}")}
  #                   ON #{table_name}.id = #{sanitize_sql("track_records_#{column_suffix}")}.tracked_id"
  #   )
  # end
    
  # def self.ranked_online_in(year)
  #   where(id: TrackRecord.online.on_year(year).by_tracked_type(self).select(:tracked_id))
  # end

  # def self.ranked_offline_in(year)
  #   where(id: TrackRecord.offline.on_year(year).by_tracked_type(self).select(:tracked_id))
  # end

  def points_online_all_time
    track_records.online.all_time.sum(:points)
  end

  def points_online_in(year)
    track_records.online.on_year(year).sum(:points)
  end

  def points_offline_all_time
    track_records.offline.all_time.sum(:points)
  end

  def points_offline_in(year)
    track_records.offline.on_year(year).sum(:points)
  end

  # def rank_online_all_time
  #   track_records.online.all_time.first&.rank
  # end

  # def rank_online_in(year)
  #   track_records.online.on_year(year).first&.rank
  # end

  # def rank_offline_all_time
  #   track_records.offline.all_time.first&.rank
  # end

  # def rank_offline_in(year)
  #   track_records.offline.on_year(year).first&.rank
  # end

  def best_met_reward_condition_online_all_time
    track_records.online.all_time.order(:best_reward_level1, :best_reward_level2).last&.best_met_reward_condition
  end

  def best_met_reward_condition_online_in(year)
    track_records.online.on_year(year).order(:best_reward_level1, :best_reward_level2).last&.best_met_reward_condition
  end

  def best_met_reward_condition_offline_all_time
    track_records.offline.all_time.order(:best_reward_level1, :best_reward_level2).last&.best_met_reward_condition
  end

  def best_met_reward_condition_offline_in(year)
    track_records.offline.on_year(year).order(:best_reward_level1, :best_reward_level2).last&.best_met_reward_condition
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
