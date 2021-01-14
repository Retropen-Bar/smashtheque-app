ActiveAdmin.register RecurringTournament do

  decorate_with ActiveAdmin::RecurringTournamentDecorator

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess-knight"></i>Tournois'.html_safe,
       label: 'Séries',
       priority: 0

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :contacts

  index do
    selectable_column
    id_column
    column :name
    column :tournament_events do |decorated|
      decorated.tournament_events_admin_link
    end
    column :recurring_type do |decorated|
      decorated.recurring_type_text
    end
    column 'Date' do |decorated|
      decorated.full_date
    end
    column :is_online
    column :level do |decorated|
      decorated.level_status
    end
    column :size
    column :contacts do |decorated|
      decorated.contacts_admin_links(size: 32).join('<br/>').html_safe
    end
    column :is_archived
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all, default: true
  scope :archived

  scope :online, group: :location
  scope :offline, group: :location

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
  filter :is_archived

  action_item :rebuild,
              only: :index,
              if: proc { current_user.is_root? } do
    link_to 'Rebuild', [:rebuild, :admin, :recurring_tournaments], class: 'blue'
  end
  collection_action :rebuild do
    RetropenBotScheduler.rebuild_online_tournaments
    redirect_to request.referer, notice: 'Demande effectuée'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :name
      f.input :date_description
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
      users_input f, :contacts
      f.input :is_archived
    end
    f.actions
  end

  permit_params :name, :recurring_type, :date_description, :wday, :starts_at,
                :discord_guild_id, :is_online, :level, :size, :registration,
                :is_archived, contact_ids: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :tournament_events do |decorated|
        decorated.tournament_events_admin_link
      end
      row :recurring_type do |decorated|
        decorated.recurring_type_text
      end
      row 'Date' do |decorated|
        decorated.full_date
      end
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
      row :is_archived
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
