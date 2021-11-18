# == Schema Information
#
# Table name: players
#
#  id              :bigint           not null, primary key
#  ban_details     :text
#  character_names :text             default([]), is an Array
#  is_accepted     :boolean
#  is_banned       :boolean          default(FALSE), not null
#  name            :string
#  old_names       :string           default([]), is an Array
#  team_names      :text             default([]), is an Array
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  creator_user_id :integer          not null
#  user_id         :integer
#
# Indexes
#
#  index_players_on_creator_user_id  (creator_user_id)
#  index_players_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_user_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
class Player < ApplicationRecord
  # ---------------------------------------------------------------------------
  # CONCERNS
  # ---------------------------------------------------------------------------

  include HasName
  def self.on_abc_name
    :name
  end

  include HasTrackRecords

  include PgSearch::Model

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :creator_user, class_name: :User
  belongs_to :user, optional: true

  has_one :discord_user, through: :user

  has_many :discord_guild_relateds, as: :related, dependent: :destroy
  has_many :discord_guilds, through: :discord_guild_relateds

  has_many :you_tube_channels, as: :related, dependent: :nullify

  has_many :twitch_channels, as: :related, dependent: :nullify

  has_many :characters_players,
           -> { positioned },
           inverse_of: :player,
           dependent: :destroy
  has_many :characters,
           through: :characters_players

  has_many :players_teams,
           -> { positioned },
           inverse_of: :player,
           dependent: :destroy
  has_many :teams,
           through: :players_teams,
           after_remove: :after_remove_team

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
  before_validation :set_team_names

  def set_character_names
    self.character_names = characters.reload.map(&:name)
  end

  def set_team_names
    self.team_names = teams.reload.map(&:name)
  end

  validates :name, presence: true
  validates :user_id, uniqueness: { allow_nil: true }

  # ---------------------------------------------------------------------------
  # CALLBACKS
  # ---------------------------------------------------------------------------

  def old_names=(_old_names)
    super _old_names.reject(&:blank?)
  end

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

  def smashgg_url=(smashgg_url)
    return if smashgg_url.blank?

    slug = SmashggUser.slug_from_url(smashgg_url)
    return if slug.blank?

    smashgg_user = SmashggUser.where(slug: slug).first_or_initialize
    if smashgg_user.persisted?
      # check if SmashggUser was already linked to another player
      return if smashgg_user.player_id != id
    else
      smashgg_user.fetch_smashgg_data
      smashgg_user.save!
    end

    self.smashgg_user_ids = (
      smashgg_user_ids + [smashgg_user.id]
    ).uniq
  end

  def discord_id=(discord_id)
    if discord_id.blank?
      self.user = nil
    else
      user = DiscordUser.where(discord_id: discord_id)
                        .first_or_create!
                        .return_or_create_user!
      # check if User was already linked to another player
      errors.add :base, 'Compte Discord déjà relié à un autre joueur' if user.player&.id != id
      self.user = user
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

  def after_remove_team(team)
    UpdateTeamTrackRecordsJob.perform_later(team)
  end

  # ---------------------------------------------------------------------------
  # SCOPES
  # ---------------------------------------------------------------------------

  pg_search_scope :by_pg_search,
                  against: [:name, :old_names],
                  using: {
                    tsearch: {
                      prefix: true
                    }
                  },
                  ignoring: :accents

  def self.by_name(name)
    where(name: name)
  end

  def self.by_name_like(name)
    where('unaccent(name) ILIKE unaccent(?)', name)
  end

  def self.by_name_contains_like(term)
    where("unaccent(name) ILIKE unaccent(?)", "%#{term}%")
  end

  def self.by_keyword(term)
    by_name_contains_like(term).or(
      where(id: by_pg_search(term).select(:id))
    )
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

  def self.with_user
    where.not(user_id: nil)
  end

  def self.without_user
    where(user_id: nil)
  end

  def self.with_potential_user
    self.without_user
        .joins(
          "INNER JOIN (#{User.without_player.to_sql}) potential_users
                   ON unaccent(potential_users.name)
                ILIKE unaccent(players.name)"
        )
  end

  def self.with_address
    where(user_id: User.with_address.select(:id))
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

  def self.recurring_tournament_contacts
    where(user_id: RecurringTournamentContact.select(:user_id))
  end

  def self.team_admins
    where(user_id: TeamAdmin.select(:user_id))
  end

  def self.near_community(community, radius: 50)
    where(user_id: User.near_community(community, radius: radius))
  end

  def self.by_community_id(community_id)
    near_community(Community.find(community_id))
  end

  def self.by_character_id(character_id)
    where(
      id: CharactersPlayer.where(character_id: character_id).select(:player_id)
    )
  end

  def self.by_main_character_id(character_id)
    where(
      id: CharactersPlayer.mains.where(character_id: character_id).select(:player_id)
    )
  end

  def self.by_team_id(team_id)
    where(
      id: PlayersTeam.where(team_id: team_id).select(:player_id)
    )
  end

  def self.by_main_countrycode(countrycode)
    from_users = where(user_id: User.by_main_countrycode(countrycode))
    if [countrycode].flatten.include?(nil)
      without_user.or(from_users)
    else
      from_users
    end
  end

  def self.by_main_countrycode_unknown_or_fr
    by_main_countrycode(['', 'FR'])
  end

  def self.by_main_countrycode_unknown_or_french_speaking
    by_main_countrycode(['', 'FR'] + User::FRENCH_SPEAKING_COUNTRIES)
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

  def refetch_smashgg_users
    smashgg_users.each do |smashgg_user|
      smashgg_user.fetch_smashgg_data
      return false unless smashgg_user.save
    end
    true
  end

  def move_results_to!(other_player_id)
    TournamentEvent::TOP_RANKS.each do |rank|
      TournamentEvent.where(
        self.class.sanitize_sql("top#{rank}_player_id") => id
      ).find_each do |tournament_event|
        tournament_event.send("top#{rank}_player_id=", other_player_id)
        tournament_event.save!
      end
    end
  end

  # ---------------------------------------------------------------------------
  # GLOBAL SEARCH
  # ---------------------------------------------------------------------------

  multisearchable against: %i[name old_names]

  # ---------------------------------------------------------------------------
  # VERSIONS
  # ---------------------------------------------------------------------------

  has_paper_trail unless: proc { ENV['NO_PAPERTRAIL'] }
end
