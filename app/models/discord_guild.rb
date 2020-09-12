# == Schema Information
#
# Table name: discord_guilds
#
#  id               :bigint           not null, primary key
#  icon             :string
#  invitation_url   :string
#  name             :string
#  related_type     :string
#  splash           :string
#  twitter_username :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  discord_id       :string
#  related_id       :bigint
#
# Indexes
#
#  index_discord_guilds_on_related_type_and_related_id  (related_type,related_id)
#
class DiscordGuild < ApplicationRecord

  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include RelatedConcern
  def self.related_types
    [
      Character,
      Location,
      Player,
      Team
    ]
  end

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_many :discord_guild_admins,
           inverse_of: :discord_guild,
           dependent: :destroy
  has_many :admins,
           through: :discord_guild_admins,
           source: :discord_user

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :discord_id,
            uniqueness: {
              allow_nil: true
            }

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_create_commit :fetch_discord_data_later
  def fetch_discord_data_later
    FetchDiscordGuildDataJob.perform_later(self)
  end

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    RetropenBotScheduler.rebuild_discord_guilds_chars_list
  end

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

  def fetch_discord_data
    client = DiscordClient.new
    data = client.get_guild discord_id
    if data.has_key?('name')
      self.attributes = {
        name: data['name'],
        icon: data['icon'],
        splash: data['splash']
      }
    end
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
