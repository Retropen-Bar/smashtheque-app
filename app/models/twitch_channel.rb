# == Schema Information
#
# Table name: twitch_channels
#
#  id                 :bigint           not null, primary key
#  description        :text
#  display_name       :string
#  is_french          :boolean          default(FALSE), not null
#  profile_image_url  :string
#  related_type       :string
#  slug               :string           not null
#  twitch_created_at  :datetime
#  twitch_description :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  related_id         :bigint
#  twitch_id          :string
#
# Indexes
#
#  index_twitch_channels_on_related_type_and_related_id  (related_type,related_id)
#  index_twitch_channels_on_slug                         (slug) UNIQUE
#
class TwitchChannel < ApplicationRecord

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
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :twitch_id, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] }
  def update_discord
    RetropenBotScheduler.rebuild_twitch
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.french
    where(is_french: true)
  end

  def self.not_french
    where(is_french: false)
  end

  def self.on_abc(letter)
    where("unaccent(name) ILIKE '#{letter}%'")
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def fetch_twitch_data
    if api_data = twitch_client.get_users({login: slug}).data&.first
      #<Twitch::User:0x00007fc22d9316a0 @id="456306239", @login="retropenbar", @display_name="RetropenBar", @type="", @broadcaster_type="", @description="Bienvenue sur le stream du Rétropen-Bar!  A ta santé ! :P", @profile_image_url="https://static-cdn.jtvnw.net/jtv_user_pictures/42c732bd-9e5f-47b8-a5be-ee65d7f3ecdf-profile_image-300x300.png", @offline_image_url="https://static-cdn.jtvnw.net/jtv_user_pictures/cee4d45b-c723-4cd2-892e-5fe219e661c6-channel_offline_image-1920x1080.jpeg", @view_count=1430, @created_at="2019-08-21T23:51:21.427712Z">
      self.twitch_id = api_data.id
      self.display_name = api_data.display_name
      self.twitch_description = api_data.description
      self.profile_image_url = api_data.profile_image_url
      self.twitch_created_at = DateTime.parse(JSON.parse(api_data.to_json)['created_at'])
    end
  end

  def self.fetch_unknown
    where(twitch_id: nil).find_each do |twitch_channel|
      twitch_channel.fetch_twitch_data
      twitch_channel.save!
      # we need to wait a bit between each request,
      # otherwise Twitch returns empty results
      sleep 1
    end
  end

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

  private

  def twitch_client
    @twitch_client ||= Twitch::Client.new(client_id: ENV['TWITCH_CLIENT_ID'], client_secret: ENV['TWITCH_CLIENT_SECRET'])
  end

end
