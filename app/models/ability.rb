class Ability
  include CanCan::Ability

  ADMIN_LEVEL_HELP = '0_help'.freeze
  ADMIN_LEVEL_ADMIN = '1_admin'.freeze
  ADMIN_LEVELS = [ADMIN_LEVEL_HELP, ADMIN_LEVEL_ADMIN]

  def initialize(_user)
    alias_action :create, :read, :update, :history, :batch_action, to: :cruhb
    alias_action :create, :read, :update, :destroy, :history, :batch_action, to: :crudhb
    alias_action :read, :history, to: :rh

    @user = _user || User.new

    admin_level = user.admin_level || ADMIN_LEVEL_HELP

    manage_or_cru = admin_level >= ADMIN_LEVEL_ADMIN ? :manage : :cruhb
    manage_or_crud = admin_level >= ADMIN_LEVEL_ADMIN ? :manage : :crudhb
    manage_or_read = admin_level >= ADMIN_LEVEL_ADMIN ? :manage : :rh

    # User
    can manage_or_crud, User, { is_root: false }
    can :read, User, { is_root: true }

    # ApiRequest
    if admin_level >= ADMIN_LEVEL_ADMIN
      can :read, ApiRequest
    end

    # ApiToken
    # only root

    # BraacketTournament
    can manage_or_cru, BraacketTournament
    can :fetch_provider_data, BraacketTournament

    # ChallongeTournament
    can manage_or_cru, ChallongeTournament
    can :fetch_provider_data, ChallongeTournament

    # Character
    can manage_or_cru, Character

    # Community
    can manage_or_cru, Community

    # DiscordGuild
    can manage_or_cru, DiscordGuild
    can :fetch_discord_data, DiscordGuild

    # DiscordGuildAdmin
    can manage_or_cru, DiscordGuildAdmin

    # DiscordUser
    can manage_or_cru, DiscordUser
    can :fetch_discord_data, DiscordUser

    # Duo
    can manage_or_crud, Duo
    can :results, Duo

    # Page
    can manage_or_cru, Page

    # Player
    can manage_or_crud, Player
    can :accept, Player
    can :results, Player

    # PlayersRecurringTournament
    can manage_or_cru, PlayersRecurringTournament

    # Reward, RewardCondition & MetRewardCondition
    can manage_or_read, Reward
    can manage_or_read, RewardCondition
    can :read, MetRewardCondition

    # SmashggEvent
    can manage_or_cru, SmashggEvent
    can :fetch_provider_data, SmashggEvent

    # SmashggUser
    can manage_or_cru, SmashggUser
    can :fetch_smashgg_data, SmashggUser

    # Tournaments
    can manage_or_crud, RecurringTournament
    [
      TournamentEvent,
      DuoTournamentEvent
    ].each do |klass|
      can manage_or_crud, klass
      can :complete_with_bracket, klass
      can :compute_rewards, klass
      can :convert_to_duo_tournament_event, klass
      can :convert_to_tournament_event, klass
      can :purge_graph, klass
    end

    # Team
    can manage_or_crud, Team

    # TwitchChannel
    can manage_or_crud, TwitchChannel
    can :fetch_twitch_data, TwitchChannel

    # YouTubeChannel
    can manage_or_crud, YouTubeChannel

    # Other admin pages
    can :read, ActiveAdmin::Page, name: 'Dashboard'
    can :read, ActiveAdmin::Page, name: 'Search'

    # root
    if user.is_root?
      can :manage, :all
    end
  end

  def user
    @user
  end

  def can?(action, subject, *extra_args)
    while subject.is_a?(Draper::Decorator)
      subject = subject.model
    end

    super(action, subject, *extra_args)
  end
end
