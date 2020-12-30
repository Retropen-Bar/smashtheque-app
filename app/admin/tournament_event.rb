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
    column :bracket_url do |decorated|
      decorated.bracket_icon_link
    end
    column :bracket do |decorated|
      decorated.bracket_admin_link
    end
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

  scope :on_smashgg, group: :bracket
  scope :on_braacket, group: :bracket
  scope :on_challonge, group: :bracket

  filter :recurring_tournament
  filter :name
  filter :date
  filter :bracket_url
  filter :participants_count
  filter :is_complete

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    columns do
      column do
        panel 'Bracket' do
          f.inputs do
            f.input :bracket_url
            f.input :bracket_gid,
                    {
                      as: :select,
                      collection: [
                        [
                          f.object.bracket&.decorate&.autocomplete_name,
                          f.object.bracket&.to_global_id&.to_s
                        ]
                      ],
                      input_html: {
                        data: {
                          select2: {
                            ajax: {
                              url: url_for(action: :bracket_autocomplete),
                              dataType: 'json'
                            },
                            placeholder: 'Nom du joueur',
                            allowClear: true
                          }
                        }
                      }
                    }
          end
        end
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
                :bracket_url, :bracket_gid,
                :graph

  collection_action :bracket_autocomplete do
    render json: TournamentEvent.bracket_autocomplete(params[:term])
  end

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
          row :bracket do |decorated|
            decorated.bracket_admin_link
          end
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

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
  end

  action_item :update_with_smashgg,
              only: :show,
              if: proc { resource.is_on_smashgg? } do
    link_to 'Mettre à jour avec smash.gg',
            { action: :update_with_smashgg },
            class: 'orange'
  end
  member_action :update_with_smashgg do
    if resource.update_with_smashgg
      redirect_to request.referer, notice: 'Données mises à jour'
    else
      puts "Model errors: #{resource.errors.full_messages}"
      puts "Bracket errors: #{resource.bracket&.errors&.full_messages}"
      flash[:error] = 'Mise à jour échouée'
      redirect_to request.referer
    end
  end

  action_item :update_with_challonge,
              only: :show,
              if: proc { resource.is_on_challonge? } do
    link_to 'Mettre à jour avec Challonge',
            { action: :update_with_challonge },
            class: 'orange'
  end
  member_action :update_with_challonge do
    if resource.update_with_challonge
      redirect_to request.referer, notice: 'Données mises à jour'
    else
      puts "Model errors: #{resource.errors.full_messages}"
      puts "Bracket errors: #{resource.bracket&.errors&.full_messages}"
      flash[:error] = 'Mise à jour échouée'
      redirect_to request.referer
    end
  end

  action_item :compute_rewards, only: :show do
    link_to 'Recalculer les récompenses',
            { action: :compute_rewards },
            class: 'blue'
  end
  member_action :compute_rewards do
    resource.compute_rewards
    redirect_to request.referer, notice: 'Calcul effectué'
  end

end
