ActiveAdmin.register MetRewardCondition do
  decorate_with ActiveAdmin::MetRewardConditionDecorator

  menu parent: '<i class="fas fa-fw fa-chess"></i>Compétition'.html_safe,
       label: '<i class="fas fa-fw fa-trophy"></i>Récompenses obtenues'.html_safe,
       priority: 5

  actions :index, :show

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :awarded, :event, :reward_condition,
           reward: { image_attachment: :blob }

  index do
    selectable_column
    id_column
    column :awarded, &:awarded_admin_link
    column :reward, &:reward_admin_link
    column :points
    column :event, &:event_admin_link
    column :reward_condition, &:reward_condition_admin_link
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
    DuoTournamentEvent.compute_all_rewards
    redirect_to request.referer, notice: 'Recalcul terminé'
  end

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :id
      row :awarded, &:awarded_admin_link
      row :reward, &:reward_admin_link
      row :points
      row :event, &:event_admin_link
      row :reward_condition, &:reward_condition_admin_link
      row :created_at
      row :updated_at
    end
  end
end
