ActiveAdmin.register PlayersRecurringTournament do

  decorate_with ActiveAdmin::PlayersRecurringTournamentDecorator

  menu parent: '<i class="fas fa-fw fa-chess"></i>Compétition'.html_safe,
       label: '<i class="fas fa-fw fa-stamp"></i>Certifications'.html_safe

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

  scope :all, default: true

  scope :with_good_network, group: :has_good_network
  scope :with_bad_network, group: :has_good_network

  filter :recurring_tournament,
         input_html: { multiple: true, data: { select2: {} } }

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :recurring_tournament,
              collection: tournament_event_recurring_tournament_select_collection,
              input_html: {
                data: {
                  select2: {
                    placeholder: 'Nom de la série',
                    allowClear: true
                  }
                }
              },
              include_blank: "Aucun"
      player_input f
      f.input :has_good_network
      user_input f, :certifier_user
    end
    f.actions
  end

  permit_params :recurring_tournament_id, :player_id, :certifier_user_id,
                :has_good_network

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
