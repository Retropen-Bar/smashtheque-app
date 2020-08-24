ActiveAdmin.register Player do

  decorate_with PlayerDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-user"></i>Joueurs'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :characters, :city, :creator, :discord_user, :team

  index do
    selectable_column
    id_column
    column :name
    column :discord_user do |decorated|
      decorated.discord_user_admin_link(size: 32)
    end
    column :characters do |decorated|
      decorated.characters_links.join(' ').html_safe
    end
    column :city do |decorated|
      decorated.city_link
    end
    column :team do |decorated|
      decorated.team_link
    end
    column :creator do |decorated|
      decorated.creator_link(size: 32)
    end
    column :is_accepted
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all, default: true

  scope :accepted, group: :is_accepted
  scope :to_be_accepted, group: :is_accepted

  scope :with_discord_user, group: :discord_user
  scope :without_discord_user, group: :discord_user

  filter :creator,
         as: :select,
         collection: proc { DiscordUser.order(:username).decorate },
         input_html: { multiple: true, data: { select2: {} } }
  filter :name
  filter :characters,
         as: :select,
         collection: proc { Character.order(:name).decorate },
         input_html: { multiple: true, data: { select2: {} } }
  filter :city,
         as: :select,
         collection: proc { City.order(:name).decorate },
         input_html: { multiple: true, data: { select2: {} } }
  filter :team,
         as: :select,
         collection: proc { Team.order(:name).decorate },
         input_html: { multiple: true, data: { select2: {} } }
  filter :is_accepted

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
              collection: DiscordUser.order(:username),
              input_html: { data: { select2: {} } }
      f.input :characters,
              collection: Character.order(:name),
              input_html: { multiple: true, data: { select2: { sortable: true, sortedValues: f.object.character_ids } } }
      f.input :city,
              collection: City.order(:name),
              input_html: { data: { select2: {} } }
      f.input :team,
              collection: Team.order(:name),
              input_html: { data: { select2: {} } }
      f.input :is_accepted
    end
    f.actions
  end

  permit_params :name, :city_id, :team_id, :is_accepted, :discord_user_id, character_ids: []

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
        decorated.characters_links.join('<br/>').html_safe
      end
      row :city do |decorated|
        decorated.city_link
      end
      row :team do |decorated|
        decorated.team_link
      end
      row :creator do |decorated|
        decorated.creator_link(size: 32)
      end
      row :is_accepted
      row :created_at
      row :updated_at
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
    redirect_to [:admin, resource]
  end

end
