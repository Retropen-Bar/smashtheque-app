ActiveAdmin.register Reward do

  decorate_with ActiveAdmin::RewardDecorator

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess-knight"></i>Tournois'.html_safe,
       label: 'Récompenses',
       priority: 2

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  order_by(:level) do |order_clause|
    if order_clause.order == 'desc'
      'level1 DESC, level2 DESC'
    else
      'level1, level2'
    end
  end
  config.sort_order = 'level_asc'

  index do
    selectable_column
    id_column
    column :name
    column :level, sortable: true
    column :emoji do |decorated|
      decorated.badge
    end
    column :reward_conditions do |decorated|
      decorated.reward_conditions_admin_link
    end
    column :player_reward_conditions do |decorated|
      decorated.player_reward_conditions_admin_link
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :name
  filter :level1
  filter :level2

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :name
      f.input :level1
      f.input :level2
      f.input :emoji
    end
    f.actions
  end

  permit_params :name, :level1, :level2, :emoji

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :level
      row :badge do |decorated|
        decorated.all_badge_sizes(count: 99)
      end
      row :reward_conditions do |decorated|
        decorated.reward_conditions_admin_link
      end
      row :player_reward_conditions do |decorated|
        decorated.player_reward_conditions_admin_link
      end
      row :players do |decorated|
        decorated.players_admin_link
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
