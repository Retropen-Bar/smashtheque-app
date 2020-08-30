class Player < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :creator, class_name: :DiscordUser
  belongs_to :location, optional: true
  belongs_to :team, optional: true
  belongs_to :discord_user, optional: true

  has_many :characters_players,
           -> { positioned },
           inverse_of: :player,
           dependent: :destroy
  has_many :characters,
           through: :characters_players,
           after_remove: :after_remove_character

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  before_validation :set_character_names

  validates :name, presence: true
  validates :discord_user, uniqueness: { allow_nil: true }

  def set_character_names
    self.character_names = characters.reload.map(&:name)
  end

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # trick to add position
  def character_ids=(_ids)
    # ids may come as strings here
    ids = _ids.map(&:to_i) - [0]
    super(ids)
    characters_players.each do |characters_player|
      idx = ids.index(characters_player.character_id)
      characters_player.update_attribute :position, idx
    end
  end

  def discord_id=(discord_id)
    if discord_id
      self.discord_user = DiscordUser.where(discord_id: discord_id).first_or_create!
    else
      self.discord_user = nil
    end
  end

  def creator_discord_id=(discord_id)
    self.creator = DiscordUser.where(discord_id: discord_id).first_or_create!
  end

  def location_name=(location_name)
    if location_name
      # Location#by_name_like does a weird search, so we need to precise @name for create
      self.location = Location.by_name_like(location_name).first_or_create!(name: location_name)
    else
      self.location = nil
    end
  end
  def city_name=(city_name)
    location_name=(city_name)
  end

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] || !is_accepted? }
  def update_discord
    # on create: previous_changes = {"id"=>[nil, <id>], "name"=>[nil, <name>], ...}
    # on update: previous_changes = {"name"=>["old_name", "new_name"], ...}
    # on delete: destroyed? = true and old attributes are available

    if destroyed?
      # this is a deletion
      RetropenBot.default.rebuild_abc_for_name name
      RetropenBot.default.rebuild_locations_for_location location if location
    else
      # name
      if previous_changes.has_key?('name')
        # this is creation or an update with changes on the name
        old_name = previous_changes['name'].first
        new_name = previous_changes['name'].last
        if RetropenBot.default.name_letter(old_name) != RetropenBot.default.name_letter(new_name)
          RetropenBot.default.rebuild_abc_for_name old_name
        end
        RetropenBot.default.rebuild_abc_for_name new_name

      else
        # this is an update, and the name didn't change
        RetropenBot.default.rebuild_abc_for_name name
      end

      # location
      if previous_changes.has_key?('location_id')
        # this is creation or an update with changes on the location_id
        old_location_id = previous_changes['location_id'].first
        new_location_id = previous_changes['location_id'].last
        RetropenBot.default.rebuild_locations_for_location Location.find(old_location_id) if old_location_id
        RetropenBot.default.rebuild_locations_for_location Location.find(new_location_id) if new_location_id

      else
        # this is an update, and the location_id didn't change
        RetropenBot.default.rebuild_locations_for_location location
      end

      # team
      if previous_changes.has_key?('team_id') || team_id
        # player was added to a team, removed from a team, or updated
        # while it belongs to a team so the teams lineups must be updated
        RetropenBot.default.rebuild_teams_lu
      end
    end

    # this handles both existing and new characters
    RetropenBot.default.rebuild_chars_for_characters characters
  end

  # this is required because removing a has_many relation
  # is not visible inside an after_commit callback
  def after_remove_character(character)
    return true if ENV['NO_DISCORD']
    RetropenBot.default.rebuild_chars_for_character character
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  def self.by_name(name)
    where(name: name)
  end

  def self.by_name_like(name)
    where('unaccent(name) ILIKE unaccent(?)', name)
  end

  def self.by_discord_id(discord_id)
    if discord_id.blank?
      where(discord_user: nil)
    else
      joins(:discord_user).where(discord_users: { discord_id: discord_id })
    end
  end

  def self.accepted
    where(is_accepted: true)
  end

  def self.to_be_accepted
    where(is_accepted: [nil, false])
  end

  def self.on_abc(letter)
    letter == '$' ? on_abc_others : where("unaccent(name) ILIKE '#{letter}%'")
  end

  def self.on_abc_others
    result = self
    ('a'..'z').each do |letter|
      result = result.where.not("unaccent(name) ILIKE '#{letter}%'")
    end
    result
  end

  def self.with_discord_user
    where.not(discord_user_id: nil)
  end

  def self.without_discord_user
    where(discord_user_id: nil)
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  delegate :discord_id,
           to: :discord_user,
           allow_nil: true

  delegate :discord_id,
           to: :creator,
           prefix: true

  def as_json(options = nil)
    result = super((options || {}).merge(
      include: {
        # characters: {
        #   only: %i(id emoji name)
        # },
        location: {
          only: %i(id icon name)
        },
        creator: {
          only: %i(id discord_id)
        },
        discord_user: {
          only: %i(id discord_id)
        },
        team: {
          only: %i(id name)
        }
      },
      methods: %i(creator_discord_id discord_id) #character_ids
    ))
    # temp hack until we find why sometimes order is not OK
    result[:character_ids] = characters_players.sort_by(&:position).map(&:character_id)
    result[:characters] = characters_players.sort_by(&:position).map(&:character).map do |c|
      {
        id: c.id,
        emoji: c.emoji,
        name: c.name
      }
    end
    result[:location] = nil unless result.has_key?('location')
    result[:team] = nil unless result.has_key?('team')
    result[:discord_user] = nil unless result.has_key?('discord_user')
    result
  end

  # ---------------------------------------------------------------------------
  # GLOBAL SEARCH
  # ---------------------------------------------------------------------------

  include PgSearch::Model
  multisearchable against: %i(name)

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
