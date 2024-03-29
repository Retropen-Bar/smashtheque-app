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
    column 'Localisation', :is_online, sortable: :is_online, &:online_status
    column :level, &:short_level_status
    column :size
    column :contacts do |decorated|
      decorated.contacts_admin_links(size: 32).join('<br/>').html_safe
    end
    column 'Stoppée', :is_archived
    column 'Masquée', :is_hidden
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
  filter :is_online
  filter :by_closest_community_id,
         as: :select,
         label: 'Communauté',
         collection: proc { recurring_tournament_community_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :locality,
         as: :select,
         label: 'Ville (exacte)',
         collection: proc { recurring_tournament_locality_select_collection },
         input_html: { multiple: true, data: { select2: {} } }

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
          f.input :ruleset, as: :action_text
          f.input :lagtest, as: :action_text, wrapper_html: { class: 'online-fields' }
        end
        f.inputs 'Contacts' do
          users_input f, :contacts
          f.input :twitter_username
          f.input :discord_guild,
                  collection: recurring_tournament_discord_guild_select_collection,
                  input_html: { data: { select2: {} } }
          f.input :registration, as: :action_text
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
          address_input f,
                        label: '<span class="offline-fields">Adresse du lieu</span>
                                <span class="online-fields">Pays organisateur</span>'.html_safe
          f.input :address_name, wrapper_html: { class: 'offline-fields' }
          f.input :misc, as: :action_text
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
          f.input :starts_at_hour,
                  hint: "Laissez 0 pour ne pas afficher d'horaire"
          f.input :starts_at_min
        end
        f.inputs 'Power rankings' do
          f.has_many  :power_rankings,
                      new_record: 'Ajouter',
                      remove_record: 'Supprimer',
                      heading: false,
                      allow_destroy: true do |pr|
            pr.input :name
            pr.input :year
            pr.input :url
          end
        end
      end
    end
    columns do
      column do
        f.inputs 'Logo' do
          f.input :logo,
                  as: :file,
                  hint: 'Laissez vide pour ne pas changer',
                  input_html: {
                    accept: 'image/*',
                    data: {
                      previewpanel: 'current-logo'
                    }
                  }
          panel '', id: 'current-logo' do
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
                :locality, :countrycode,
                :twitter_username, :misc,
                :ruleset, :lagtest,
                :is_archived, :is_hidden, contact_ids: [],
                power_rankings_attributes: %i[id name year url _destroy]

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
          row :ruleset, &:formatted_ruleset
          row :lagtest, &:formatted_lagtest
          row :contacts do |decorated|
            decorated.contacts_admin_links(size: 32).join('<br/>').html_safe
          end
          row :address_name
          row :address, &:address_with_coordinates
          row :locality
          row :countrycode, &:country_name
          row :closest_community, &:closest_community_admin_link
          row :twitter_username, &:twitter_link
          row :misc, &:formatted_misc
          row :power_rankings, &:power_rankings_list
          row :is_archived
          row :is_hidden
          row :created_at
          row :updated_at
        end
      end
      column do
        render 'map' if resource.is_offline? && resource.geocoded?
      end
    end
    active_admin_comments
  end

  action_item :other_actions, only: :show do
    dropdown_menu 'Autres actions' do
      if resource.logo.attached?
        item 'Supprimer le logo', action: :purge_logo
      end
    end
  end

  member_action :purge_logo do
    resource.logo.purge
    redirect_to request.referer, notice: 'Logo supprimé'
  end

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
  end

  member_action :map
end
