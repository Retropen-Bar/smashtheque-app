ActiveAdmin.register Duo do

  decorate_with ActiveAdmin::DuoDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-user-friends"></i>Duos'.html_safe,
       parent: '<i class="far fa-fw fa-user"></i>Fiches'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes player1: { user: :discord_user },
           player2: { user: :discord_user }

  index do
    selectable_column
    id_column
    column :name do |decorated|
      decorated.admin_link
    end
    column :player1 do |decorated|
      decorated.player1_admin_link
    end
    column :player2 do |decorated|
      decorated.player2_admin_link
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :name
  filter :rank
  filter :points
  filter :best_reward,
         as: :select,
         collection: proc { Reward.online_2v2.admin_decorate },
         input_html: { multiple: true, data: { select2: {} } }

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :name
      player_input f, name: :player1
      player_input f, name: :player2
    end
    f.actions
  end

  permit_params :name, :player1_id, :player2_id

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :player1 do |decorated|
        decorated.player1_admin_link
      end
      row :player2 do |decorated|
        decorated.player2_admin_link
      end
      row :rank
      row :points
      Player::POINTS_YEARS.each do |year|
        row "rank_in_#{year}"
        row "points_in_#{year}"
      end
      row :best_reward do |decorated|
        decorated.best_reward_admin_link
      end
      row :best_rewards do |decorated|
        decorated.best_rewards_admin_links({}, class: 'reward-badge-32').join(' ').html_safe
      end
      row :unique_rewards do |decorated|
        decorated.unique_rewards_admin_links({}, class: 'reward-badge-32').join(' ').html_safe
      end
      row :created_at
      row :updated_at
    end
  end

  action_item :results,
              only: :show do
    link_to 'Résultats', [:results, :admin, resource]
  end

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
  end

  # ---------------------------------------------------------------------------
  # RESULTS
  # ---------------------------------------------------------------------------

  member_action :results do
    @duo = resource.admin_decorate
    @duo_tournament_events = @duo.duo_tournament_events
                                 .order(date: :desc)
                                 .admin_decorate
    @rewards_counts = @duo.rewards_counts
    @rewards_count = @rewards_counts.values.sum
    @duo_tournament_events_count = @duo_tournament_events.count
  end

end
