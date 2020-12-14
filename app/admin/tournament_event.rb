ActiveAdmin.register TournamentEvent do

  decorate_with ActiveAdmin::TournamentEventDecorator

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess-knight"></i>Tournois'.html_safe,
       label: 'Tournois'

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :name
    column :date
    column :recurring_tournament
    TournamentEvent::PLAYER_NAMES.each do |player_name|
      column player_name do |decorated|
        decorated.send("#{player_name}_admin_link")
      end
    end
    actions
  end

  filter :name
  filter :date
  filter :recurring_tournament

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :name
      f.input :date
      f.input :recurring_tournament,
              collection: tournament_event_recurring_tournament_select_collection,
              input_html: {
                data: {
                  select2: {
                    placeholder: 'Nom de la série',
                    allowClear: true
                  }
                }
              },
              include_blank: "Aucun"
      TournamentEvent::PLAYER_NAMES.each do |player_name|
        player_input f, player_name
      end
    end
    f.actions
  end

  permit_params :name, :date, :recurring_tournament_id,
                :top1_player_id, :top2_player_id, :top3_player_id,
                :top4_player_id, :top5a_player_id, :top5b_player_id,
                :top7a_player_id, :top7b_player_id

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :date
      row :recurring_tournament
      TournamentEvent::PLAYER_NAMES.each do |player_name|
        row player_name do |decorated|
          decorated.send("#{player_name}_admin_link")
        end
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
