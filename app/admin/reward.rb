ActiveAdmin.register Reward do

  decorate_with ActiveAdmin::RewardDecorator

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess-knight"></i>Tournois'.html_safe,
       label: 'Récompenses',
       priority: 2

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :name
    column :image do |decorated|
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

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :name
      f.input :image
      f.input :style
    end
    f.actions
  end

  permit_params :name, :image, :style

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :badge do |decorated|
        decorated.all_badge_sizes(count: 99)
      end
      row :image do |decorated|
        decorated.image_tag(max_width: 64, style: "background: black")
      end
      row :style do |decorated|
        decorated.formatted_style
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
