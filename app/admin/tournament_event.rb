ActiveAdmin.register TournamentEvent do

  decorate_with ActiveAdmin::TournamentEventDecorator

  sidebar 'Autres éditions', only: :show do
    div class: 'tournament-events-nav-links' do
      resource.tournament_events_nav_links
    end
  end

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess-rook"></i>Compétition 1v1'.html_safe,
       label: '<i class="fas fa-fw fa-calendar-alt"></i>Éditions'.html_safe,
       priority: 1

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  order_by(:bracket) do |order_clause|
    if order_clause.order == 'desc'
      'bracket_type DESC, bracket_id DESC'
    else
      'bracket_type, bracket_id'
    end
  end

  includes :recurring_tournament, :bracket,
           top1_player: [:smashgg_users, { user: :discord_user }],
           top2_player: [:smashgg_users, { user: :discord_user }],
           top3_player: [:smashgg_users, { user: :discord_user }],
           top4_player: [:smashgg_users, { user: :discord_user }],
           top5a_player: [:smashgg_users, { user: :discord_user }],
           top5b_player: [:smashgg_users, { user: :discord_user }],
           top7a_player: [:smashgg_users, { user: :discord_user }],
           top7b_player: [:smashgg_users, { user: :discord_user }]

  index do
    selectable_column
    id_column
    column :recurring_tournament
    column :name do |decorated|
      link_to decorated.name, [:admin, decorated.model]
    end
    column :date
    column :bracket_url do |decorated|
      decorated.bracket_icon_link
    end
    column :bracket, sortable: :bracket do |decorated|
      decorated.bracket_admin_link
    end
    column :participants_count
    TournamentEvent::PLAYER_NAMES.each do |player_name|
      column player_name do |decorated|
        decorated.send("#{player_name}_admin_link")
      end
    end
    column :is_complete
    column :is_out_of_ranking
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
  filter :is_out_of_ranking

  collection_action :update_available_brackets do
    UpdateAvailableBracketsJob.perform_later
    redirect_to request.referer, notice: 'Données en cours de récupération'
  end

  action_item :other_actions, only: :index do
    dropdown_menu 'Autres actions' do
      if TournamentEvent.with_available_bracket.any?
        available_brackets_count = TournamentEvent.with_available_bracket.count
        item "Récupérer les #{available_brackets_count} brackets disponibles",
                action: :update_available_brackets
      end
    end
  end

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
                            placeholder: 'Nom du bracket',
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
              hint = f.object.decorate.send("#{player_name}_bracket_suggestion")
              player_input f, name: player_name, hint: hint
            end
            f.input :is_complete
            f.input :is_out_of_ranking
          end
          f.actions
        end
      end
    end
  end

  permit_params :name, :date, :recurring_tournament_id, :participants_count,
                :top1_player_id, :top2_player_id, :top3_player_id,
                :top4_player_id, :top5a_player_id, :top5b_player_id,
                :top7a_player_id, :top7b_player_id,
                :is_complete, :is_out_of_ranking,
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
          row :is_out_of_ranking
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

  action_item :other_actions, only: :show do
    dropdown_menu 'Autres actions' do
      if resource.is_on_smashgg?
        item 'Mettre à jour avec smash.gg', action: :update_with_smashgg
      end
      if resource.is_on_challonge?
        item 'Mettre à jour avec Challonge', action: :update_with_challonge
      end
      item 'Recalculer les récompenses', action: :compute_rewards
      if resource.graph.attached?
        item 'Supprimer le graph', action: :purge_graph
      end
    end
  end

  member_action :purge_graph do
    resource.graph.purge
    redirect_to request.referer, notice: 'Graph supprimé'
  end

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
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

  member_action :compute_rewards do
    resource.compute_rewards
    redirect_to request.referer, notice: 'Calcul effectué'
  end

end
