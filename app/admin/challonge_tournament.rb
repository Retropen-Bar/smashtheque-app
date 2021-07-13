ActiveAdmin.register ChallongeTournament do
  decorate_with ActiveAdmin::ChallongeTournamentDecorator

  is_bracket

  menu parent: '<img src="https://assets.challonge.com/assets/challonge_fireball_orange-a973ff3b12c34c780fc21313ec71aada3b9b779cbd3a62769e9199ce08395692.svg" height="16" class="logo"/>Challonge'.html_safe,
       label: '<i class="fas fa-fw fa-chess"></i>Tournois'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :tournament_event, :duo_tournament_event

  index do
    selectable_column
    id_column
    column :any_tournament_event do |decorated|
      decorated.any_tournament_event_admin_link
    end
    column 'Tournoi', sortable: :slug do |decorated|
      decorated.challonge_link
    end
    column :start_at do |decorated|
      decorated.start_at_date
    end
    column :participants_count
    ChallongeTournament::PARTICIPANT_NAMES.each do |participant_name|
      column participant_name
    end
    column :is_ignored
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :challonge_id
  filter :slug
  filter :name
  filter :start_at
  filter :is_ignored
  filter :participants_count
  filter :created_at

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :challonge_url, placeholder: 'https://challonge.com/...'
    end
    f.actions
  end

  permit_params :challonge_id, :challonge_url

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :challonge_id
      row :slug
      row 'Tournoi' do |decorated|
        decorated.challonge_link
      end
      row :start_at
      row :participants_count
      ChallongeTournament::PARTICIPANT_NAMES.each do |participant_name|
        row participant_name
      end
      row :tournament_event do |decorated|
        decorated.tournament_event_admin_link
      end
      row :duo_tournament_event do |decorated|
        decorated.duo_tournament_event_admin_link
      end
      row :is_ignored
      row :created_at
      row :updated_at
    end
  end
end
