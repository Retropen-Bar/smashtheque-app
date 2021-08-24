ActiveAdmin.register Problem do
  decorate_with ActiveAdmin::ProblemDecorator

  menu parent: '<i class="fas fa-fw fa-chess"></i>Compétition'.html_safe,
       label: '<i class="fas fa-fw fa-exclamation-circle"></i>Problèmes signalés'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes  :player, :duo, :reporting_user,
            recurring_tournament: [
              :discord_guild,
              { logo_attachment: :blob }
            ]

  index do
    selectable_column
    column :occurred_at do |decorated|
      decorated.admin_link label: decorated.occurred_at
    end
    column :nature do |decorated|
      decorated.admin_link label: decorated.nature
    end
    column :player, &:player_admin_link
    column :duo, &:duo_admin_link
    column :recurring_tournament, &:recurring_tournament_admin_link
    column :reporting_user, &:reporting_user_admin_link
    column :created_at, &:created_at_date
    actions dropdown: true
  end

  scope :all, default: true
  scope :by_players
  scope :by_duos

  filter  :recurring_tournament,
          collection: proc { problem_recurring_tournament_select_collection },
          input_html: { multiple: true, data: { select2: {} } }
  filter  :occurred_at
  filter  :nature,
          as: :select,
          collection: proc { problem_nature_select_collection },
          input_html: { multiple: true, data: { select2: {} } }
  filter  :reporting_user,
          collection: proc { problem_existing_reporting_users_collection },
          input_html: { multiple: true, data: { select2: {} } }
  filter  :player,
          collection: proc { problem_existing_players_collection },
          input_html: { multiple: true, data: { select2: {} } }
  filter  :duo,
          collection: proc { problem_existing_duos_collection },
          input_html: { multiple: true, data: { select2: {} } }

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  controller do
    def build_new_resource
      resource = super
      resource.reporting_user = current_user
      resource.occurred_at = Date.today
      resource
    end
  end

  form do |f|
    f.inputs do
      player_input f
      duo_input f
      f.input :recurring_tournament,
              collection: problem_recurring_tournament_select_collection,
              input_html: {
                data: {
                  select2: {
                    placeholder: 'Nom de la série',
                    allowClear: true
                  }
                }
              },
              include_blank: 'Aucune'
      f.input :occurred_at
      f.input :nature,
              as: :select,
              collection: problem_nature_select_collection,
              input_html: { data: { select2: {} } }
      f.input :details,
              input_html: { rows: 5 }
      f.input :proof,
              as: :file,
              hint: 'Laissez vide pour ne pas changer'
    end
    f.actions
  end

  permit_params :player_id, :duo_id, :recurring_tournament_id,
                :occurred_at, :nature, :details, :proof

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :player, &:player_admin_link
      row :duo, &:duo_admin_link
      row :recurring_tournament, &:recurring_tournament_admin_link
      row :occurred_at
      row :nature
      row :details, &:formatted_details
      row :reporting_user, &:reporting_user_admin_link
      row :proof, &:proof_link
      row :created_at
      row :updated_at
    end
  end
end
