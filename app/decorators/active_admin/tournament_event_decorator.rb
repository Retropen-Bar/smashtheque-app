class ActiveAdmin::TournamentEventDecorator < TournamentEventDecorator
  include ActiveAdmin::BaseDecorator

  decorates :tournament_event

  TournamentEvent::PLAYER_NAMES.each do |player_name|
    define_method "#{player_name}_admin_link" do
      send(player_name)&.admin_decorate&.admin_link
    end
  end

end
