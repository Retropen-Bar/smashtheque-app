ActiveAdmin.register DuoRewardDuoCondition do

  decorate_with ActiveAdmin::DuoRewardDuoConditionDecorator

  menu parent: '<i class="fas fa-fw fa-chess-knight"></i>Compétition 2v2'.html_safe,
       label: '<i class="fas fa-fw fa-trophy"></i>Récompenses obtenues'.html_safe,
       priority: 4

  actions :index, :show

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :duo_tournament_event, :reward_duo_condition,
           duo: {
             player1: { user: :discord_user },
             player2: { user: :discord_user }
           },
           reward: { image_attachment: :blob }

  index do
    selectable_column
    id_column
    column :duo do |decorated|
      decorated.duo_admin_link
    end
    column :reward do |decorated|
      decorated.reward_admin_link
    end
    column :points
    column :duo_tournament_event do |decorated|
      decorated.duo_tournament_event_admin_link
    end
    column :reward_duo_condition do |decorated|
      decorated.reward_duo_condition_admin_link
    end
    actions
  end

  filter :reward_duo_condition,
         input_html: { multiple: true, data: { select2: {} } }
  filter :reward,
         input_html: { multiple: true, data: { select2: {} } }

  action_item :recompute_all,
              only: :index,
              if: proc { current_user.is_root? } do
    link_to 'Recalculer tout', action: :recompute_all, class: 'blue'
  end
  collection_action :recompute_all do
    DuoTournamentEvent.compute_all_rewards
    redirect_to request.referer, notice: 'Recalcul terminé'
  end

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :id
      row :duo do |decorated|
        decorated.duo_admin_link
      end
      row :reward do |decorated|
        decorated.reward_admin_link
      end
      row :points
      row :duo_tournament_event do |decorated|
        decorated.duo_tournament_event_admin_link
      end
      row :reward_duo_condition do |decorated|
        decorated.reward_duo_condition_admin_link
      end
      row :created_at
      row :updated_at
    end
  end

end
