# == Schema Information
#
# Table name: players
#
#  id               :bigint           not null, primary key
#  character_names  :text             default([]), is an Array
#  is_accepted      :boolean
#  location_names   :text             default([]), is an Array
#  name             :string
#  team_names       :text             default([]), is an Array
#  twitter_username :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  creator_id       :bigint
#  discord_user_id  :bigint
#  location_id      :bigint
#  smash_gg_user_id :bigint
#  team_id          :bigint
#
# Indexes
#
#  index_players_on_creator_id        (creator_id)
#  index_players_on_discord_user_id   (discord_user_id)
#  index_players_on_location_id       (location_id)
#  index_players_on_smash_gg_user_id  (smash_gg_user_id)
#  index_players_on_team_id           (team_id)
#
class Player < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :creator, class_name: :DiscordUser
  belongs_to :discord_user, optional: true

  has_many :characters_players,
           -> { positioned },
           inverse_of: :player,
           dependent: :destroy
  has_many :characters,
           through: :characters_players,
           after_remove: :after_remove_character

  has_many :locations_players,
           -> { positioned },
           inverse_of: :player,
           dependent: :destroy
  has_many :locations,
           through: :locations_players,
           after_remove: :after_remove_location

  has_many :players_teams,
           -> { positioned },
           inverse_of: :player,
           dependent: :destroy
  has_many :teams,
           through: :players_teams,
           after_remove: :after_remove_team

  # ---------------------------------------------------------------------------
  # VALIDATIONS
  # ---------------------------------------------------------------------------

  before_validation :set_character_names
  before_validation :set_location_names
  before_validation :set_team_names

  def set_character_names
    self.character_names = characters.reload.map(&:name)
  end

  def set_location_names
    self.location_names = locations.reload.map(&:name)
  end

  def set_team_names
    self.team_names = teams.reload.map(&:name)
  end

  validates :name, presence: true
  validates :discord_user, uniqueness: { allow_nil: true }

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  # trick to add position
  def character_ids=(_ids)
    # ids may come as strings here
    ids = (_ids.map(&:to_i) - [0]).uniq
    super(ids)
    characters_players.each do |characters_player|
      idx = ids.index(characters_player.character_id)
      characters_player.position = idx
      characters_player.save if characters_player.persisted?
    end
  end

  # trick to add position
  def location_ids=(_ids)
    # ids may come as strings here
    ids = (_ids.map(&:to_i) - [0]).uniq
    super(ids)
    locations_players.each do |locations_player|
      idx = ids.index(locations_player.location_id)
      locations_player.position = idx
      locations_player.save if locations_player.persisted?
    end
  end

  # trick to add position
  def team_ids=(_ids)
    # ids may come as strings here
    ids = (_ids.map(&:to_i) - [0]).uniq
    super(ids)
    players_teams.each do |players_team|
      idx = ids.index(players_team.team_id)
      players_team.position = idx
      players_team.save if players_team.persisted?
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

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] || !is_accepted? }
  def update_discord
    # on create: previous_changes = {"id"=>[nil, <id>], "name"=>[nil, <name>], ...}
    # on update: previous_changes = {"name"=>["old_name", "new_name"], ...}
    # on delete: destroyed? = true and old attributes are available

    if destroyed?
      # this is a deletion
      RetropenBotScheduler.rebuild_abc_for_name name
    else
      # name
      if previous_changes.has_key?('name')
        # this is creation or an update with changes on the name
        old_name = previous_changes['name'].first
        new_name = previous_changes['name'].last
        if RetropenBot.name_letter(old_name) != RetropenBot.name_letter(new_name)
          RetropenBotScheduler.rebuild_abc_for_name old_name
        end
        RetropenBotScheduler.rebuild_abc_for_name new_name

      else
        # this is an update, and the name didn't change
        RetropenBotScheduler.rebuild_abc_for_name name
      end
    end

    # this handles both existing and new characters
    RetropenBotScheduler.rebuild_chars_for_characters characters

    # this handles both existing and new locations
    RetropenBotScheduler.rebuild_locations_for_locations locations
  end

  # this is required because removing a has_many relation
  # is not visible inside an after_commit callback
  def after_remove_character(character)
    return true if ENV['NO_DISCORD'] || !is_accepted?
    RetropenBotScheduler.rebuild_chars_for_character character
  end

  # this is required because removing a has_many relation
  # is not visible inside an after_commit callback
  def after_remove_location(location)
    return true if ENV['NO_DISCORD'] || !is_accepted?
    RetropenBotScheduler.rebuild_locations_for_location location
  end

  # this is required because removing a has_many relation
  # is not visible inside an after_commit callback
  def after_remove_team(team)
    return true if ENV['NO_DISCORD'] || !is_accepted?
    RetropenBotScheduler.rebuild_teams_lu
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
    reload
    result = super((options || {}).merge(
      include: {
        characters: {
          only: %i(id emoji name)
        },
        locations: {
          only: %i(id icon name)
        },
        creator: {
          only: %i(id discord_id)
        },
        discord_user: {
          only: %i(id discord_id)
        },
        teams: {
          only: %i(id short_name name)
        }
      },
      methods: %i(
        character_ids
        creator_discord_id
        discord_id
        location_ids
        team_ids
      )
    ))
    result[:discord_user] = nil unless result.has_key?('discord_user')
    result
  end

  def potential_duplicates
    self.class.by_name_like(name).where.not(id: id)
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
