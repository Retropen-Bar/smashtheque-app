ActiveAdmin.register PlayersRecurringTournament do

  decorate_with ActiveAdmin::PlayersRecurringTournamentDecorator

  menu parent: '<i class="fas fa-fw fa-chess"></i>Compétition'.html_safe,
       label: '<i class="fas fa-fw fa-stamp"></i>Certifications'.html_safe,
       priority: 4

  actions :index, :show

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :recurring_tournament,
           player: { user: :discord_user },
           certifier_user: :discord_user

  index do
    selectable_column
    id_column
    column :recurring_tournament do |decorated|
      decorated.recurring_tournament_admin_link
    end
    column :player do |decorated|
      decorated.player_admin_link
    end
    column :has_good_network
    column :certifier_user do |decorated|
      decorated.certifier_user_admin_link
    end
    actions
  end

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :id
      row :recurring_tournament do |decorated|
        decorated.recurring_tournament_admin_link
      end
      row :player do |decorated|
        decorated.player_admin_link
      end
      row :has_good_network
      row :certifier_user do |decorated|
        decorated.certifier_user_admin_link
      end
      row :created_at
      row :updated_at
    end
  end

end
