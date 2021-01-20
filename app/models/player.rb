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
#  rank                            :integer
#  team_names                      :text             default([]), is an Array
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  best_player_reward_condition_id :bigint
#  creator_user_id                 :integer
#  user_id                         :integer
#
# Indexes
#
#  index_players_on_best_player_reward_condition_id  (best_player_reward_condition_id)
#  index_players_on_creator_user_id                  (creator_user_id)
#  index_players_on_user_id                          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (best_player_reward_condition_id => player_reward_conditions.id)
#  fk_rails_...  (creator_user_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
class Player < ApplicationRecord

  include PgSearch::Model

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :creator_user, class_name: :User
  belongs_to :user, optional: true

  has_one :discord_user, through: :user

  # cache
  belongs_to :best_player_reward_condition,
             class_name: :PlayerRewardCondition,
             optional: true

  has_one :best_reward,
          through: :best_player_reward_condition,
          source: :reward

  has_many :discord_guild_relateds, as: :related, dependent: :destroy
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

  has_many :tournament_events_as_top1_player,
           class_name: :TournamentEvent,
           foreign_key: :top1_player_id,
           dependent: :nullify
  has_many :tournament_events_as_top2_player,
           class_name: :TournamentEvent,
           foreign_key: :top2_player_id,
           dependent: :nullify
  has_many :tournament_events_as_top3_player,
           class_name: :TournamentEvent,
           foreign_key: :top3_player_id,
           dependent: :nullify
  has_many :tournament_events_as_top4_player,
           class_name: :TournamentEvent,
           foreign_key: :top4_player_id,
           dependent: :nullify
  has_many :tournament_events_as_top5a_player,
           class_name: :TournamentEvent,
           foreign_key: :top5a_player_id,
           dependent: :nullify
  has_many :tournament_events_as_top5b_player,
           class_name: :TournamentEvent,
           foreign_key: :top5b_player_id,
           dependent: :nullify
  has_many :tournament_events_as_top7a_player,
           class_name: :TournamentEvent,
           foreign_key: :top7a_player_id,
           dependent: :nullify
  has_many :tournament_events_as_top7b_player,
           class_name: :TournamentEvent,
           foreign_key: :top7b_player_id,
           dependent: :nullify

  has_many :smashgg_users, dependent: :nullify

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
  validates :user_id, uniqueness: { allow_nil: true }

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
      self.user = DiscordUser.where(discord_id: discord_id)
                             .first_or_create!
                             .return_or_create_user!
    else
      self.user = nil
    end
  end

  def creator_discord_id
    creator_user&.discord_id
  end

  def creator_discord_id=(discord_id)
    self.creator_user = DiscordUser.where(discord_id: discord_id)
                                   .first_or_create!
                                   .return_or_create_user!
  end

  after_commit :update_discord, unless: Proc.new { ENV['NO_DISCORD'] || !is_legit? }
  def update_discord
    # on create: previous_changes = {"id"=>[nil, <id>], "name"=>[nil, <name>], ...}
    # on update: previous_changes = {"name"=>["old_name", "new_name"], ...}
    # on delete: destroyed? = true and old attributes are available

    if destroyed?
      # this is a deletion
      RetropenBotScheduler.rebuild_abc_for_name name

      # if points was 0, player had 0 points and 0 rewards
      # so it was not listed anywhere in the rewards section
      if points > 0
        RetropenBotScheduler.rebuild_rewards
      end
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

      # rewards
      if previous_changes.has_key?('points') || points > 0
        RetropenBotScheduler.rebuild_rewards
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
      where(user: nil)
    else
      where.not(user_id: nil).where(
        user_id: DiscordUser.where(discord_id: discord_id)
                            .select(:user_id)
      )
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

  def self.with_user
    where.not(user_id: nil)
  end

  def self.without_user
    where(user_id: nil)
  end

  def self.without_location
    where.not(id: LocationsPlayer.select(:player_id))
  end

  def self.without_character
    where.not(id: CharactersPlayer.select(:player_id))
  end

  def self.with_smashgg_user
    where(id: SmashggUser.with_player.select(:player_id))
  end

  def self.without_smashgg_user
    where.not(id: SmashggUser.with_player.select(:player_id))
  end

  scope :with_points, -> { where("points > 0") }
  scope :ranked, -> { where.not(rank: nil) }

  scope :by_best_reward_level1, -> v { where(best_reward_level1: v) }
  scope :by_best_reward_level2, -> v { where(best_reward_level2: v) }
  def self.by_best_reward_level(a, b)
    by_best_reward_level1(a).by_best_reward_level2(b)
  end
  def self.by_best_reward(reward)
    by_best_reward_level(reward.level1, reward.level2)
  end

  # ---------------------------------------------------------------------------
  # HELPERS
  # ---------------------------------------------------------------------------

  def return_or_create_user!
    if user.nil?
      self.user = User.create!(name: name)
      save!
    end
    user
  end

  # provides: @discord_id
  delegate :discord_id,
           :twitter_username,
           to: :user,
           allow_nil: true

  # provides: @discord_user_id
  delegate :id,
           to: :discord_user,
           prefix: true,
           allow_nil: true

  def as_json(options = {})
    reload unless options.delete(:reload) == false
    result = super((options || {}).merge(
      include: {
        characters: {
          only: %i(id emoji name)
        },
        creator_user: {
          only: %i(id name)
        },
        locations: {
          only: %i(id icon name)
        },
        discord_user: {
          only: %i(id discord_id)
        },
        teams: {
          only: %i(id short_name name)
        },
        user: {
          only: %i(id name)
        }
      },
      methods: %i(
        character_ids
        creator_discord_id
        discord_id
        discord_user_id
        location_ids
        team_ids
      )
    ))
    result[:user] = nil unless result.has_key?('user')
    result
  end

  def potential_duplicates
    self.class.by_name_like(name).where.not(id: id)
  end

  def potential_user
    return nil unless user_id.nil?
    User.without_player.by_name_like(name).first
  end

  def _potential_user
    @potential_user ||= potential_user
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
      rewards.order(:level1).group(:level1).pluck(:level1, "MAX(level2)")
    ].map do |level1, level2|
      Reward.by_level(level1, level2).first
    end.sort_by(&:level2)
  end

  def update_points
    self.points = player_reward_conditions.points_total
  end

  def update_best_reward
    player_reward_condition =
      player_reward_conditions.joins(:reward)
                              .order(:level1, :level2, :points)
                              .last
    self.best_player_reward_condition = player_reward_condition
    self.best_reward_level1 = player_reward_condition&.reward&.level1
    self.best_reward_level2 = player_reward_condition&.reward&.level2
  end

  def update_cache!
    update_points
    update_best_reward
    save!
  end

  def self.update_ranks!
    subquery =
      Player.with_points
            .legit
            .select(:id, "ROW_NUMBER() OVER(ORDER BY points DESC) AS newrank")

    Player.update_all("
      rank = pointed.newrank
      FROM (#{subquery.to_sql}) pointed
      WHERE players.id = pointed.id
    ")
    Player.where.not(id: Player.with_points.legit.select(:id)).update_all(rank: nil)
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
