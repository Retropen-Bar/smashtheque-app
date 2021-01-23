module ActiveAdmin::TournamentEventBaseDecorator
  include ActiveAdmin::BaseDecorator

  def recurring_tournament_admin_link(options = {})
    recurring_tournament&.admin_decorate&.admin_link(options)
  end

  def bracket_admin_link(options = {})
    bracket&.admin_decorate&.admin_link(options)
  end

end
