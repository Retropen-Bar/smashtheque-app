ActiveAdmin.register TournamentEvent do

  decorate_with ActiveAdmin::TournamentEventDecorator

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess-knight"></i>Tournois'.html_safe,
       label: 'Éditions'

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :recurring_tournament
    column :name
    column :date
    column :participants_count
    TournamentEvent::PLAYER_NAMES.each do |player_name|
      column player_name do |decorated|
        decorated.send("#{player_name}_admin_link")
      end
    end
    actions
  end

  filter :recurring_tournament
  filter :name
  filter :date
  filter :participants_count

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    columns do
      column do
        panel 'Graph', id: 'current-graph' do
          f.object.decorate.graph_image_tag
        end
        panel '' do
          f.input :graph,
                  as: :file,
                  label: 'Nouveau graph',
                  hint: 'Laissez vide pour ne pas changer',
                  input_html: {
                    data: {
                      previewpanel: 'current-graph'
                    }
                  }
        end
      end
      column do
        panel 'Informations' do
          f.inputs do
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
            f.input :name
            f.input :date
            f.input :participants_count
            TournamentEvent::PLAYER_NAMES.each do |player_name|
              player_input f, player_name
            end
          end
          f.actions
        end
      end
    end
  end

  permit_params :name, :date, :recurring_tournament_id, :participants_count,
                :top1_player_id, :top2_player_id, :top3_player_id,
                :top4_player_id, :top5a_player_id, :top5b_player_id,
                :top7a_player_id, :top7b_player_id, :graph

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    columns do
      column do
        attributes_table do
          row :recurring_tournament
          row :name
          row :date
          row :participants_count
          TournamentEvent::PLAYER_NAMES.each do |player_name|
            row player_name do |decorated|
              decorated.send("#{player_name}_admin_link")
            end
          end
          row :created_at
          row :updated_at
        end
      end
      column do
        panel 'Graph' do
          resource.graph_image_tag(max_width: '100%')
        end
      end
    end
    active_admin_comments
  end

end
