ActiveAdmin.register Duo do

  decorate_with ActiveAdmin::DuoDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-user-friends"></i>Duos'.html_safe,
       parent: '<i class="far fa-fw fa-user"></i>Fiches'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  controller do
    def scoped_collection
      super.with_track_records_online_all_time.with_track_records_offline_all_time
    end
  end

  order_by(:points_online_all_time) do |order_clause|
    if order_clause.order == 'desc'
      'points_online_all_time DESC NULLS LAST'
    else
      'points_online_all_time ASC NULLS FIRST'
    end
  end

  order_by(:points_offline_all_time) do |order_clause|
    if order_clause.order == 'desc'
      'points_offline_all_time DESC NULLS LAST'
    else
      'points_offline_all_time ASC NULLS FIRST'
    end
  end

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
    column "<img src=\"https://cdn.discordapp.com/emojis/#{RetropenBot::EMOJI_POINTS_ONLINE}.png?size=16\"/>".html_safe,
           sortable: :points_online_all_time,
           &:points_online_all_time
    column "<img src=\"https://cdn.discordapp.com/emojis/#{RetropenBot::EMOJI_POINTS_OFFLINE}.png?size=16\"/>".html_safe,
           sortable: :points_offline_all_time,
           &:points_offline_all_time
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
      row :rank_online_all_time
      row :rank_offline_all_time
      row :points_online_all_time
      row :points_offline_all_time
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
    @resource = resource.admin_decorate
    @events = @resource.duo_tournament_events.order(date: :desc).admin_decorate
    @all_online_rewards = Reward.online_2v2
    @all_offline_rewards = Reward.offline_2v2
    @online_rewards_counts = @duo.rewards_counts(is_online: true)
    @offline_rewards_counts = @duo.rewards_counts(is_online: false)
    @rewards_count = @online_rewards_counts.values.sum + @offline_rewards_counts.values.sum
    @events_count = @events.count
    render 'admin/shared/results'
  end

end
