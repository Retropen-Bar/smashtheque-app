class Ability
  include CanCan::Ability

  LEVEL_HELP = '0_help'.freeze
  LEVEL_ADMIN = '1_admin'.freeze
  LEVELS = [LEVEL_HELP, LEVEL_ADMIN]

  def initialize(_user)
    alias_action :create, :read, :update, to: :cru

    @user = _user || AdminUser.new

    level = user.level || LEVEL_HELP

    manage_or_cru = level >= LEVEL_ADMIN ? :manage : :cru

    # AdminUser
    if level >= LEVEL_ADMIN
      can :manage, AdminUser
      cannot :manage, AdminUser, is_root: true
      can :read, AdminUser
    elsif user.persisted?
      can :read, AdminUser
    end

    # ApiRequest
    if level >= LEVEL_ADMIN
      can :read, ApiRequest
    end

    # ApiToken
    # only root

    # Character
    if level >= LEVEL_ADMIN
      can :manage, Character
    else
      can :read, Character
    end

    # DiscordUser
    if level >= LEVEL_ADMIN
      can :manage, DiscordUser
    else
      can :read, DiscordUser
    end

    # Location and subclasses
    can manage_or_cru, Location

    # Player
    can manage_or_cru, Player

    # Team
    can manage_or_cru, Team

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
