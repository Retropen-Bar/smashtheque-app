ActiveAdmin.register MetRewardCondition do

  decorate_with ActiveAdmin::MetRewardConditionDecorator

  menu parent: '<i class="fas fa-fw fa-chess"></i>Compétition'.html_safe,
       label: '<i class="fas fa-fw fa-trophy"></i>Récompenses obtenues'.html_safe,
       priority: 5

  actions :index, :show

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :record, :event, :reward_condition,
           reward: { image_attachment: :blob }

  index do
    selectable_column
    id_column
    column :player do |decorated|
      decorated.player_admin_link
    end
    column :reward do |decorated|
      decorated.reward_admin_link
    end
    column :points
    column :tournament_event do |decorated|
      decorated.tournament_event_admin_link
    end
    column :reward_condition do |decorated|
      decorated.reward_condition_admin_link
    end
    actions
  end

  filter :reward_condition,
         input_html: { multiple: true, data: { select2: {} } }
  filter :reward,
         input_html: { multiple: true, data: { select2: {} } }

  action_item :recompute_all,
              only: :index,
              if: proc { current_user.is_root? } do
    link_to 'Recalculer tout', action: :recompute_all, class: 'blue'
  end
  collection_action :recompute_all do
    TournamentEvent.compute_all_rewards
    redirect_to request.referer, notice: 'Recalcul terminé'
  end

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :id
      row :player do |decorated|
        decorated.player_admin_link
      end
      row :reward do |decorated|
        decorated.reward_admin_link
      end
      row :points
      row :tournament_event do |decorated|
        decorated.tournament_event_admin_link
      end
      row :reward_condition do |decorated|
        decorated.reward_condition_admin_link
      end
      row :created_at
      row :updated_at
    end
  end

end
