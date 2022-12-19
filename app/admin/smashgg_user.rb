ActiveAdmin.register SmashggUser do
  decorate_with ActiveAdmin::SmashggUserDecorator

  menu parent: "<img src='#{SmashggEvent::ICON_URL}' height='16' class='logo'/>start.gg".html_safe,
       label: '<i class="fas fa-fw fa-user"></i>Comptes'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes player: { user: :discord_user }

  index do
    selectable_column
    id_column
    column :slug do |decorated|
      decorated.smashgg_link
    end
    column :gamer_tag do |decorated|
      decorated.avatar_and_name(size: 32)
    end
    column :player do |decorated|
      decorated.player_admin_link
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all
  scope :unknown
  scope :with_player
  scope :without_player

  filter :smashgg_id
  filter :gamer_tag
  filter :slug
  filter :created_at

  action_item :fetch_unknown,
              only: :index,
              if: proc { SmashggUser.unknown.any? } do
    link_to 'Compléter', fetch_unknown_admin_smashgg_users_path, class: 'blue'
  end
  collection_action :fetch_unknown do
    SmashggUser.fetch_unknown
    redirect_to request.referer, notice: 'Données récupérées'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      unless f.object.persisted?
        f.input :smashgg_url, placeholder: 'https://www.start.gg/...'
      end
      player_input f
    end
    f.actions
  end

  permit_params :smashgg_id, :smashgg_url, :player_id

  before_create(&:fetch_smashgg_data)

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :player do |decorated|
        decorated.player_admin_link
      end
      row :smashgg_id
      row :slug do |decorated|
        decorated.smashgg_link
      end
      row :avatar do |decorated|
        unless decorated.avatar_url.blank?
          decorated.any_image_tag(size: 128)
        end
      end
      row :gamer_tag
      row :prefix
      row :name
      row :bio
      row :birthday
      row :gender_pronoun
      row :city
      row :country
      row :country_id
      row :state
      row :state_id
      row :banner_url do |decorated|
        decorated.banner_tag(max_height: 64)
      end
      row :twitch_username, &:twitch_link
      row :twitter_username, &:twitter_link
      row :discord_discriminated_username, &:discord_link
      row :created_at
      row :updated_at
    end
    panel 'Tournois placés', style: 'margin-top: 50px' do
      table_for resource.smashgg_events.admin_decorate,
                i18n: SmashggEvent do
        column :slug do |decorated|
          decorated.smashgg_link
        end
        column 'Placement' do |decorated|
          decorated.smashgg_user_rank_name(resource.id)
        end
      end
    end
  end

  action_item :fetch_smashgg_data,
              only: :show do
    link_to 'Importer les données de start.gg', [:fetch_smashgg_data, :admin, resource]
  end

  action_item :other_actions, only: :show do
    dropdown_menu 'Autres actions' do
      item 'Voir les tournois', action: :smashgg_events
      item 'Importer tous les tournois', action: :import_missing_smashgg_events
    end
  end

  member_action :fetch_smashgg_data do
    resource.fetch_smashgg_data
    if resource.save
      redirect_to [:admin, resource], notice: 'Import réussi'
    else
      flash[:error] = 'Import échoué'
      redirect_to request.referer
    end
  end

  member_action :import_missing_smashgg_events do
    resource.import_missing_smashgg_events
    redirect_to request.referer, notice: 'Import terminé'
  end

  # ---------------------------------------------------------------------------
  # EVENTS
  # ---------------------------------------------------------------------------

  member_action :smashgg_events do
    @smashgg_events = resource.fetch_smashgg_events
  end

  # ---------------------------------------------------------------------------
  # SUGGESTIONS
  # ---------------------------------------------------------------------------

  action_item :suggestions, only: :index do
    link_to 'Suggestions', { action: :suggestions }, class: :blue
  end
  collection_action :suggestions do
    @smashgg_users = SmashggUser.without_player
  end
end
