ActiveAdmin.register RewardCondition do

  decorate_with ActiveAdmin::RewardConditionDecorator

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess-knight"></i>Tournois'.html_safe,
       label: 'Conditions de récompense'

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  config.sort_order = 'points_asc'

  index do
    selectable_column
    id_column
    column :level do |decorated|
      decorated.level_status
    end
    column :rank do |decorated|
      decorated.rank_name
    end
    column :size_min
    column :size_max
    column :reward do |decorated|
      decorated.reward_admin_link
    end
    column :points
    actions
  end

  filter :level,
         as: :select,
         collection: proc { reward_condition_level_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
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
      f.input :level,
              collection: reward_condition_level_select_collection,
              input_html: { data: { select2: {} } },
              include_blank: false
      f.input :rank,
              as: :select,
              collection: reward_condition_rank_select_collection,
              input_html: { data: { select2: {} } },
              include_blank: false
      f.input :size_min
      f.input :size_max
      f.input :reward,
              collection: reward_condition_reward_select_collection,
              input_html: { data: { select2: {} } }
      f.input :points
    end
    f.actions
  end

  permit_params :level, :rank, :size_min, :size_max, :reward_id, :points

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :level do |decorated|
        decorated.level_status
      end
      row :rank do |decorated|
        decorated.rank_name
      end
      row :size_min
      row :size_max
      row :reward do |decorated|
        decorated.reward_admin_link
      end
      row :points
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
