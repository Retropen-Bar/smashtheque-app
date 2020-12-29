# == Schema Information
#
# Table name: smashgg_events
#
#  id              :bigint           not null, primary key
#  is_online       :boolean
#  name            :string
#  num_entrants    :integer
#  slug            :string           not null
#  starts_at       :datetime
#  tournament_name :string
#  tournament_slug :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  smashgg_id      :integer          not null
#  tournament_id   :integer
#
# Indexes
#
#  index_smashgg_events_on_slug        (slug) UNIQUE
#  index_smashgg_events_on_smashgg_id  (smashgg_id) UNIQUE
#
class SmashggEvent < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  has_one :tournament_event, dependent: :nullify

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  validates :smashgg_id, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.with_tournament_event
    where(id: TournamentEvent.select(:smashgg_event_id))
  end
  def self.without_tournament_event
    where.not(id: TournamentEvent.select(:smashgg_event_id))
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def self.from_slug(slug)
    o = where(slug: slug).first_or_initialize
    o.fetch_smashgg_data
    o
  end

  def self.slug_from_url(url)
    url.slice(/tournament\/[^\/]+\/event\/[^\/]+/)
  end

  def self.from_url(url)
    from_slug(slug_from_url(url))
  end

  def fetch_smashgg_data
    if smashgg_id
      data = SmashggClient.new.get_event_data(id: smashgg_id)
    elsif slug
      data = SmashggClient.new.get_event_data(slug: slug)
    else
      raise 'No ID or slug provided'
    end

    self.smashgg_id = data.event.id
    self.slug = data.event.slug

    self.name = data.event.name
    self.starts_at = Time.at(data.event.start_at)
    self.is_online = data.event.is_online
    self.num_entrants = data.event.num_entrants

    self.tournament_id = data.event.tournament.id
    self.tournament_slug = data.event.tournament.slug
    self.tournament_name = data.event.tournament.name
  end

  def smashgg_url
    "https://smash.gg/#{slug}"
  end

  def smashgg_url=(url)
    self.slug = self.class.slug_from_url(url)
  end

end
