ActiveAdmin.register RecurringTournament do

  decorate_with ActiveAdmin::RecurringTournamentDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-chess-knight"></i>Tournois'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :contacts

  index do
    selectable_column
    id_column
    column :name
    column :recurring_type do |decorated|
      decorated.recurring_type_text
    end
    column :wday do |decorated|
      decorated.wday_text
    end
    column :starts_at
    column :is_online
    column :level do |decorated|
      decorated.level_status
    end
    column :size
    column :contacts do |decorated|
      decorated.contacts_admin_links(size: 32).join('<br/>').html_safe
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all, default: true
  scope :online
  scope :offline

  filter :name
  filter :recurring_type,
         as: :select,
         collection: proc { recurring_tournament_recurring_type_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :wday,
         as: :select,
         collection: proc { recurring_tournament_wday_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :level,
         as: :select,
         collection: proc { recurring_tournament_level_select_collection },
         input_html: { multiple: true, data: { select2: {} } }

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :name
      f.input :recurring_type,
              collection: recurring_tournament_recurring_type_select_collection,
              input_html: { data: { select2: {} } },
              include_blank: false
      f.input :wday,
              as: :select,
              collection: recurring_tournament_wday_select_collection,
              input_html: { data: { select2: {} } },
              include_blank: false
      f.input :starts_at
      f.input :discord_guild,
              collection: recurring_tournament_discord_guild_select_collection,
              input_html: { data: { select2: {} } }
      f.input :is_online
      f.input :level,
              collection: recurring_tournament_level_select_collection,
              input_html: { data: { select2: {} } },
              include_blank: false
      f.input :size,
              as: :select,
              collection: recurring_tournament_size_select_collection
      f.input :registration,
              input_html: { rows: 5 }
      discord_users_input f, :contacts
    end
    f.actions
  end

  permit_params :name, :recurring_type, :wday, :starts_at, :discord_guild_id,
                :is_online, :level, :size, :registration,
                contact_ids: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :recurring_type do |decorated|
        decorated.recurring_type_text
      end
      row :wday do |decorated|
        decorated.wday_text
      end
      row :starts_at
      row :discord_guild do |decorated|
        decorated.discord_guild_admin_link
      end
      row :is_online
      row :level do |decorated|
        decorated.level_status
      end
      row :size
      row :registration do |decorated|
        decorated.formatted_registration
      end
      row :contacts do |decorated|
        decorated.contacts_admin_links(size: 32).join('<br/>').html_safe
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
