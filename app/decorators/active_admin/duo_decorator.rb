class ActiveAdmin::DuoDecorator < DuoDecorator
  include ActiveAdmin::BaseDecorator

  decorates :duo

  def player1_admin_link(options = {})
    player1&.admin_decorate&.admin_link(options)
  end

  def player2_admin_link(options = {})
    player2&.admin_decorate&.admin_link(options)
  end

end
