module ActiveAdmin
  class DuoTournamentEventDecorator < DuoTournamentEventDecorator
    include ActiveAdmin::TournamentEventBaseDecorator

    decorates :duo_tournament_event

    DuoTournamentEvent::TOP_NAMES.each do |duo_name|
      define_method "#{duo_name}_admin_link" do
        send(duo_name)&.admin_decorate&.admin_link
      end
    end
  end
end
