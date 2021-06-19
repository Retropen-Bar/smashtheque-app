ActiveAdmin.register RecurringTournament do
  decorate_with ActiveAdmin::RecurringTournamentDecorator

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-chess"></i>Compétition'.html_safe,
       label: '<i class="fas fa-fw fa-calendar-alt"></i>Séries'.html_safe,
       priority: 0

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes contacts: :discord_user,
           logo_attachment: :blob

  index do
    selectable_column
    id_column
    column :logo do |decorated|
      decorated.logo_image_tag(max_height: 32)
    end
    column :name do |decorated|
      link_to decorated.name, [:admin, decorated.model]
    end
    column :tournament_events, &:tournament_events_admin_link
    column :duo_tournament_events, &:duo_tournament_events_admin_link
    column :recurring_type, &:recurring_type_text
    column 'Date', &:full_date
    column :is_online
    column :level, &:short_level_status
    column :size
    column :contacts do |decorated|
      decorated.contacts_admin_links(size: 32).join('<br/>').html_safe
    end
    column :is_archived
    column :is_hidden
    column :created_at, &:created_at_date
    actions
  end

  scope :all, default: true

  scope :archived, group: :special
  scope :hidden, group: :special

  scope :online, group: :loctype
  scope :offline, group: :loctype

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
  filter :is_hidden

  action_item :rebuild,
              only: :index,
              if: proc { current_user.is_root? } do
    link_to 'Rebuild', %i[rebuild admin recurring_tournaments], class: 'blue'
  end
  collection_action :rebuild do
    RetropenBotScheduler.rebuild_online_tournaments
    redirect_to request.referer, notice: 'Demande effectuée'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    render 'admin/shared/google_places_api'
    f.semantic_errors(*f.object.errors.keys)
    columns do
      column do
        f.inputs 'La série' do
          f.input :name
          f.input :level,
                  collection: recurring_tournament_level_select_collection,
                  input_html: { data: { select2: {} } },
                  include_blank: false
          f.input :size,
                  as: :select,
                  collection: recurring_tournament_size_select_collection
          f.input :is_archived
          f.input :is_hidden
        end
        f.inputs 'Contacts' do
          users_input f, :contacts
          f.input :twitter_username
          f.input :discord_guild,
                  collection: recurring_tournament_discord_guild_select_collection,
                  input_html: { data: { select2: {} } }
          f.input :registration,
                  input_html: { rows: 5 }
        end
      end
      column do
        f.inputs 'Localisation' do
          f.input :is_online,
                  input_html: {
                    data: {
                      toggle: '.online-fields',
                      untoggle: '.offline-fields'
                    }
                  }
          f.input :address_name, wrapper_html: { class: 'offline-fields' }
          div class: 'offline-fields' do
            address_input f
          end
          f.input :misc,
                  input_html: { rows: 5 }
        end
        f.inputs 'Temporalité' do
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
          f.input :starts_at_hour
          f.input :starts_at_min
        end
      end
    end
    f.inputs 'Logo' do
      columns do
        column do
          f.input :logo,
                  as: :file,
                  hint: 'Laissez vide pour ne pas changer',
                  input_html: {
                    accept: 'image/*',
                    data: {
                      previewpanel: 'current-logo'
                    }
                  }
        end
        column do
          panel 'Logo', id: 'current-logo' do
            f.object.decorate.logo_image_tag
          end
        end
      end
    end
    f.actions
  end

  permit_params :name, :recurring_type, :logo,
                :date_description, :wday, :starts_at_hour, :starts_at_min,
                :discord_guild_id, :is_online, :level, :size, :registration,
                :address_name, :address, :latitude, :longitude,
                :twitter_username, :misc,
                :is_archived, :is_hidden, contact_ids: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    columns do
      column do
        attributes_table do
          row :name
          row :logo do |decorated|
            decorated.logo_image_tag(max_height: 64)
          end
          row :tournament_events, &:tournament_events_admin_link
          row :duo_tournament_events, &:duo_tournament_events_admin_link
          row :recurring_type, &:recurring_type_text
          row 'Date', &:full_date
          row :discord_guild, &:discord_guild_admin_link
          row :is_online
          row :level, &:level_status
          row :size
          row :registration, &:formatted_registration
          row :contacts do |decorated|
            decorated.contacts_admin_links(size: 32).join('<br/>').html_safe
          end
          row :address_name
          row :address, &:address_with_coordinates
          row :twitter_username, &:twitter_link
          row :misc, &:formatted_misc
          row :is_archived
          row :is_hidden
          row :created_at
          row :updated_at
        end
      end
      column do
        if resource.geocoded?
          single_address_map({
            name: resource.full_address.html_safe,
            latitude: resource.latitude,
            longitude: resource.longitude
          })
        end
      end
    end
    active_admin_comments
  end

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
  end
end
