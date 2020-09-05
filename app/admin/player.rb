ActiveAdmin.register Player do

  decorate_with ActiveAdmin::PlayerDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-user"></i>Joueurs'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :characters, :locations, :creator, :discord_user, :teams

  index do
    selectable_column
    id_column
    column :name do |decorated|
      link_to decorated.name_or_indicated_name, [:admin, decorated.model]
    end
    column :discord_user do |decorated|
      decorated.discord_user_admin_link(size: 32)
    end
    column :characters do |decorated|
      decorated.characters_admin_links.join(' ').html_safe
    end
    column :locations do |decorated|
      decorated.locations_admin_links.join('<br/>').html_safe
    end
    column :teams do |decorated|
      decorated.teams_admin_links.join('<br/>').html_safe
    end
    column :creator do |decorated|
      decorated.creator_admin_link(size: 32)
    end
    column :is_accepted
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions do |decorated|
      if !decorated.is_accepted? && !decorated.model.potential_duplicates.any?
        link_to 'Valider', [:accept, :admin, decorated.model], class: 'member_link green'
      end
    end
  end

  scope :all, default: true

  scope :accepted, group: :is_accepted
  scope :to_be_accepted, group: :is_accepted

  scope :with_discord_user, group: :discord_user
  scope :without_discord_user, group: :discord_user

  filter :creator,
         as: :select,
         collection: proc { player_creator_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :name
  filter :characters,
         as: :select,
         collection: proc { player_characters_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :locations,
         as: :select,
         collection: proc { player_locations_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :teams,
         as: :select,
         collection: proc { player_teams_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :is_accepted

  action_item :rebuild_all,
              only: :index,
              if: proc { current_admin_user.is_root? } do
    link_to 'Rebuild', [:rebuild_all, :admin, :players], class: 'blue'
  end
  collection_action :rebuild_all do
    RetropenBotScheduler.rebuild_all
    redirect_to request.referer, notice: 'Demande effectuée'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  controller do
    def build_new_resource
      resource = super
      resource.creator = current_admin_user.discord_user
      resource
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :discord_user,
              collection: player_discord_user_select_collection,
              input_html: { data: { select2: {} } }
      f.input :characters,
              collection: player_characters_select_collection,
              input_html: { multiple: true, data: { select2: { sortable: true, sortedValues: f.object.character_ids } } }
      f.input :locations,
              collection: player_locations_select_collection,
              include_blank: 'Aucune',
              input_html: { multiple: true, data: { select2: { sortable: true, sortedValues: f.object.location_ids } } }
      f.input :teams,
              collection: player_teams_select_collection,
              include_blank: 'Aucune',
              input_html: { multiple: true, data: { select2: { sortable: true, sortedValues: f.object.team_ids } } }
      f.input :is_accepted
    end
    f.actions
  end

  permit_params :name, :is_accepted, :discord_user_id,
                character_ids: [], location_ids: [], team_ids: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :discord_user do |decorated|
        decorated.discord_user_admin_link(size: 32)
      end
      row :characters do |decorated|
        decorated.characters_admin_links.join('<br/>').html_safe
      end
      row :locations do |decorated|
        decorated.locations_admin_links.join('<br/>').html_safe
      end
      row :teams do |decorated|
        decorated.teams_admin_links.join('<br/>').html_safe
      end
      row :creator do |decorated|
        decorated.creator_admin_link(size: 32)
      end
      row :is_accepted
      row :created_at
      row :updated_at
    end
    panel 'Doublons potentiels', style: 'margin-top: 50px' do
      table_for resource.potential_duplicates.decorate, i18n: Player do
        column :name do |decorated|
          decorated.admin_link
        end
        column :characters do |decorated|
          decorated.characters_admin_links.join(' ').html_safe
        end
        column :locations do |decorated|
          decorated.locations_admin_links.join(' ').html_safe
        end
        column :teams do |decorated|
          decorated.teams_admin_links.join(' ').html_safe
        end
        column :creator do |decorated|
          decorated.creator_admin_link(size: 32)
        end
        column :is_accepted
        column :created_at do |decorated|
          decorated.created_at_date
        end
      end
    end
    active_admin_comments
  end

  action_item :accept,
              only: :show,
              if: proc { !resource.is_accepted? } do
    link_to 'Valider', [:accept, :admin, resource], class: 'green'
  end
  member_action :accept do
    resource.update_attribute :is_accepted, true
    redirect_to request.referer
  end

end
