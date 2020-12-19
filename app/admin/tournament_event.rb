ActiveAdmin.register TournamentEvent do

  decorate_with ActiveAdmin::TournamentEventDecorator

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess-knight"></i>Tournois'.html_safe,
       label: 'Éditions',
       priority: 1

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
    column :is_complete
    actions
  end

  scope :all, default: true
  scope :with_missing_graph
  scope :with_missing_players
  scope :with_missing_data

  filter :recurring_tournament
  filter :name
  filter :date
  filter :participants_count
  filter :is_complete

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
                    accept: 'image/*',
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
            f.input :bracket_url
            TournamentEvent::PLAYER_NAMES.each do |player_name|
              player_input f, player_name
            end
            f.input :is_complete
          end
          f.actions
        end
      end
    end
  end

  permit_params :name, :date, :recurring_tournament_id, :participants_count,
                :top1_player_id, :top2_player_id, :top3_player_id,
                :top4_player_id, :top5a_player_id, :top5b_player_id,
                :top7a_player_id, :top7b_player_id, :is_complete,
                :bracket_url, :graph

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
          row :bracket_url do |decorated|
            decorated.bracket_link
          end
          TournamentEvent::PLAYER_NAMES.each do |player_name|
            row player_name do |decorated|
              decorated.send("#{player_name}_admin_link")
            end
          end
          row :is_complete
          row :created_at
          row :updated_at
        end
        panel 'Récompenses obtenues', style: 'margin-top: 50px' do
          table_for resource.player_reward_conditions.admin_decorate,
                    i18n: PlayerRewardCondition do
            column :reward_condition do |decorated|
              decorated.reward_condition_admin_link
            end
            column :player do |decorated|
              decorated.player_admin_link
            end
            column :reward do |decorated|
              decorated.reward_admin_link
            end
            column :points
          end
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

  action_item :previous, only: :show do
    resource.previous_tournament_event_admin_link label: '←', class: 'blue'
  end

  action_item :next, only: :show do
    resource.next_tournament_event_admin_link label: '→', class: 'blue'
  end

  action_item :compute_rewards, only: :show do
    link_to 'Recalculer les récompenses',
            action: :compute_rewards,
            class: 'blue'
  end
  member_action :compute_rewards do
    resource.compute_rewards
    redirect_to request.referer, notice: 'Calcul effectué'
  end

end
