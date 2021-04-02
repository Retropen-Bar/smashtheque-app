class ActiveAdmin::PlayersRecurringTournamentDecorator < PlayersRecurringTournamentDecorator
  include ActiveAdmin::BaseDecorator

  decorates :players_recurring_tournament

  def player_admin_link(options = {})
    player&.admin_decorate&.admin_link(options)
  end

  def recurring_tournament_admin_link(options = {})
    recurring_tournament&.admin_decorate&.admin_link(options)
  end

  def certifier_user_admin_link(options = {})
    certifier_user&.admin_decorate&.admin_link(options)
  end

  def name
    [
      player.name,
      recurring_tournament.name
    ].join(' @ ')
  end
end
