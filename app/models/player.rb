# == Schema Information
#
# Table name: players
#
#  id                              :bigint           not null, primary key
#  ban_details                     :text
#  best_reward_level1              :string
#  best_reward_level2              :string
#  character_names                 :text             default([]), is an Array
#  is_accepted                     :boolean
#  is_banned                       :boolean          default(FALSE), not null
#  location_names                  :text             default([]), is an Array
#  name                            :string
#  points                          :integer          default(0), not null
#  team_names                      :text             default([]), is an Array
#  twitter_username                :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  best_player_reward_condition_id :bigint
#  creator_id                      :bigint
#  discord_user_id                 :bigint
#
# Indexes
#
#  index_players_on_best_player_reward_condition_id  (best_player_reward_condition_id)
#  index_players_on_creator_id                       (creator_id)
#  index_players_on_discord_user_id                  (discord_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (best_player_reward_condition_id => player_reward_conditions.id)
#
class Player < ApplicationRecord

  include PgSearch::Model

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :creator, class_name: :DiscordUser
  belongs_to :discord_user, optional: true

  # cache
  belongs_to :best_player_reward_condition,
             class_name: :PlayerRewardCondition,
             optional: true

  has_one :best_reward,
          through: :best_player_reward_condition,
          source: :reward

  has_many :discord_guild_relateds, as: :related, dependent: :nullify
  has_many :discord_guilds, through: :discord_guild_relateds

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

  has_many :player_reward_conditions, dependent: :destroy
  has_many :reward_conditions, through: :player_reward_conditions
  has_many :rewards, through: :player_reward_conditions

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

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] || !is_legit? }
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
    return true if ENV['NO_DISCORD'] || !is_legit?
    RetropenBotScheduler.rebuild_chars_for_character character
  end

  # this is required because removing a has_many relation
  # is not visible inside an after_commit callback
  def after_remove_location(location)
    return true if ENV['NO_DISCORD'] || !is_legit?
    RetropenBotScheduler.rebuild_locations_for_location location
  end

  # this is required because removing a has_many relation
  # is not visible inside an after_commit callback
  def after_remove_team(team)
    return true if ENV['NO_DISCORD'] || !is_legit?
    RetropenBotScheduler.rebuild_teams_lu
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  pg_search_scope :by_keyword,
                  against: [:name],
                  using: {
                    tsearch: { prefix: true }
                  }

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

  def self.banned
    where(is_banned: true)
  end

  def self.not_banned
    where(is_banned: false)
  end

  def self.legit
    accepted.not_banned
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

  def self.without_location
    where.not(id: LocationsPlayer.select(:player_id))
  end

  def self.without_character
    where.not(id: CharactersPlayer.select(:player_id))
  end

  scope :by_best_reward_level1, -> v { where(best_reward_level1: v) }

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

  def is_legit?
    is_accepted? && !is_banned?
  end

  def tournament_events
    TournamentEvent.with_player(id)
  end

  # returns a hash { reward_id => count }
  def rewards_counts
    rewards.ordered_by_level.group(:id).count
  end

  def unique_rewards
    Reward.where(id: rewards.select(:id))
  end

  def best_rewards
    Hash[
      rewards.group(:level1).pluck(:level1, "MAX(level2)")
    ].map do |level1, level2|
      Reward.by_level(level1, level2).first
    end.sort_by(&:level2)
  end

  def update_points
    self.points = player_reward_conditions.points_total
  end

  def update_best_player_reward_condition
    self.best_player_reward_condition_id =
      player_reward_conditions.joins(:reward_condition)
                              .order(:points)
                              .last
                              .id
  end

  def update_best_reward_level
    reward = rewards.ordered_by_level.last
    self.best_reward_level1 = reward&.level1
    self.best_reward_level2 = reward&.level2
  end

  def update_cache!
    update_points
    update_best_player_reward_condition
    update_best_reward_level
    save!
  end

  # ---------------------------------------------------------------------------
  # GLOBAL SEARCH
  # ---------------------------------------------------------------------------

  multisearchable against: %i(name)

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: Proc.new { ENV['NO_PAPERTRAIL'] }

end
