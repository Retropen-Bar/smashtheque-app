ActiveAdmin.register RewardCondition do

  decorate_with ActiveAdmin::RewardConditionDecorator

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess"></i>Compétition'.html_safe,
       label: '<i class="fas fa-fw fa-fire"></i>Conditions de récompense'.html_safe,
       priority: 4

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  config.sort_order = 'points_asc'

  index do
    selectable_column
    id_column
    column :rank, &:rank_name
    column :is_online
    column :is_duo
    column :size_min
    column :size_max
    column :reward, &:reward_admin_link
    column :points
    column :met_reward_conditions, &:met_reward_conditions_admin_link
    actions
  end

  scope :all, default: true

  scope :online, group: :online
  scope :online_1v1, group: :online
  scope :online_2v2, group: :online

  scope :offline, group: :offline
  scope :offline_1v1, group: :offline
  scope :offline_2v2, group: :offline

  filter :rank,
         as: :select,
         collection: proc { reward_condition_rank_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :size_min
  filter :size_max
  filter :reward,
         as: :select,
         collection: proc { reward_condition_reward_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :points

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :rank,
              as: :select,
              collection: reward_condition_rank_select_collection,
              input_html: { data: { select2: {} } },
              include_blank: false
      f.input :is_online
      f.input :is_duo
      f.input :size_min
      f.input :size_max
      f.input :reward,
              collection: reward_condition_reward_select_collection,
              input_html: { data: { select2: {} } }
      f.input :points
    end
    f.actions
  end

  permit_params :rank, :is_online, :is_duo, :size_min, :size_max, :reward_id, :points

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :rank, &:rank_name
      row :is_online
      row :is_duo
      row :size_min
      row :size_max
      row :reward, &:reward_admin_link
      row :points
      row :met_reward_conditions, &:met_reward_conditions_admin_link
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
