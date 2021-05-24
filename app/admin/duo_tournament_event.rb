ActiveAdmin.register DuoTournamentEvent do
  decorate_with ActiveAdmin::DuoTournamentEventDecorator

  sidebar 'Autres éditions', only: :show do
    div class: 'tournament-events-nav-links' do
      resource.events_nav_links
    end
  end

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess"></i>Compétition'.html_safe,
       label: '<i class="fas fa-fw fa-chess-knight"></i>Éditions 2v2'.html_safe,
       priority: 2

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
           top1_duo: {
             player1: { user: :discord_user },
             player2: { user: :discord_user }
           },
           top2_duo: {
             player1: { user: :discord_user },
             player2: { user: :discord_user }
           },
           top3_duo: {
             player1: { user: :discord_user },
             player2: { user: :discord_user }
           },
           top4_duo: {
             player1: { user: :discord_user },
             player2: { user: :discord_user }
           },
           top5a_duo: {
             player1: { user: :discord_user },
             player2: { user: :discord_user }
           },
           top5b_duo: {
             player1: { user: :discord_user },
             player2: { user: :discord_user }
           },
           top7a_duo: {
             player1: { user: :discord_user },
             player2: { user: :discord_user }
           },
           top7b_duo: {
             player1: { user: :discord_user },
             player2: { user: :discord_user }
           }

  index do
    selectable_column
    id_column
    column :recurring_tournament
    column :name do |decorated|
      link_to decorated.name, [:admin, decorated.model]
    end
    column :date
    column :bracket_url, &:bracket_icon_link
    column :bracket, sortable: :bracket, &:bracket_admin_link
    column :is_online, &:online?
    column :participants_count
    DuoTournamentEvent::DUO_NAMES.each do |duo_name|
      column duo_name do |decorated|
        decorated.send("#{duo_name}_admin_link")
      end
    end
    column :is_online, &:online?
    column :is_complete
    column :is_out_of_ranking
    actions
  end

  scope :all, default: true

  scope :with_missing_graph, group: :missing
  scope :with_missing_duos, group: :missing
  scope :with_missing_data, group: :missing

  scope :on_smashgg, group: :bracket
  scope :on_braacket, group: :bracket
  scope :on_challonge, group: :bracket

  scope :online, group: :location
  scope :offline, group: :location

  filter :recurring_tournament
  filter :name
  filter :date
  filter :bracket_url
  filter :participants_count
  filter :is_complete
  filter :is_out_of_ranking

  action_item :update_available_brackets,
              only: :index,
              if: proc { DuoTournamentEvent.with_available_bracket.any? } do
    available_brackets_count = DuoTournamentEvent.with_available_bracket.count
    link_to "Récupérer les #{available_brackets_count} brackets disponibles",
            update_available_brackets_admin_duo_tournament_events_path,
            class: 'blue'
  end
  collection_action :update_available_brackets do
    DuoTournamentEvent.update_available_brackets
    redirect_to request.referer, notice: 'Données récupérées'
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
                    include_blank: 'Aucun'
            f.input :name
            f.input :date
            f.input :participants_count
            DuoTournamentEvent::DUO_NAMES.each do |duo_name|
              hint = f.object.decorate.send("#{duo_name}_bracket_suggestion")
              duo_input f, name: duo_name, hint: hint
            end
            f.input :is_online, hint: "Seulement si le tournoi n'appartient pas à une série"
            f.input :is_complete
            f.input :is_out_of_ranking
          end
          f.actions
        end
      end
    end
  end

  permit_params :name, :date, :recurring_tournament_id, :participants_count,
                :top1_duo_id, :top2_duo_id, :top3_duo_id,
                :top4_duo_id, :top5a_duo_id, :top5b_duo_id,
                :top7a_duo_id, :top7b_duo_id,
                :is_online, :is_complete, :is_out_of_ranking,
                :bracket_url, :bracket_gid,
                :graph

  collection_action :bracket_autocomplete do
    render json: DuoTournamentEvent.bracket_autocomplete(params[:term])
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
          row :bracket_url, &:bracket_link
          DuoTournamentEvent::DUO_NAMES.each do |duo_name|
            row duo_name do |decorated|
              decorated.send("#{duo_name}_admin_link")
            end
          end
          row :is_online, &:online?
          row :is_complete
          row :is_out_of_ranking
          row :bracket, &:bracket_admin_link
          row :created_at
          row :updated_at
        end
        panel 'Récompenses obtenues', style: 'margin-top: 50px' do
          table_for resource.duo_reward_duo_conditions.admin_decorate,
                    i18n: DuoRewardDuoCondition do
            column :reward_duo_condition, &:reward_duo_condition_admin_link
            column :duo, &:duo_admin_link
            column :reward, &:reward_admin_link
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
      item 'Compléter avec smash.gg', action: :complete_with_bracket if resource.is_on_smashgg?
      item 'Compléter avec Braacket', action: :complete_with_bracket if resource.is_on_braacket?
      item 'Compléter avec Challonge', action: :complete_with_bracket if resource.is_on_challonge?
      item 'Recalculer les récompenses', action: :compute_rewards
      item 'Supprimer le graph', action: :purge_graph if resource.graph.attached?
    end
  end

  member_action :purge_graph do
    resource.graph.purge
    redirect_to request.referer, notice: 'Graph supprimé'
  end

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
  end

  member_action :complete_with_bracket do
    if resource.complete_with_bracket && resource.save
      redirect_to request.referer, notice: 'Données mises à jour'
    else
      Rails.logger.debug "Model errors: #{resource.errors.full_messages}"
      Rails.logger.debug "Bracket errors: #{resource.bracket&.errors&.full_messages}"
      flash[:error] = 'Mise à jour échouée'
      redirect_to request.referer
    end
  end

  member_action :compute_rewards do
    resource.compute_rewards
    redirect_to request.referer, notice: 'Calcul effectué'
  end
end
