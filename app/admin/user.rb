ActiveAdmin.register User do

  decorate_with ActiveAdmin::UserDecorator

  menu label: '<i class="fas fa-fw fa-user-secret"></i>Utilisateurs'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :discord_user, :player, :administrated_teams, :administrated_recurring_tournaments

  index do
    selectable_column
    id_column
    column :name do |decorated|
      decorated.admin_link(size: 32)
    end
    column :admin_level do |decorated|
      decorated.admin_level_status
    end
    column :discord_user do |decorated|
      decorated.discord_user_admin_link(size: 32)
    end
    column :player do |decorated|
      decorated.player_admin_link
    end
    column :created_players do |decorated|
      decorated.created_players_admin_link
    end
    column :administrated_teams do |decorated|
      decorated.administrated_teams_admin_links(size: 32).join('<br/>').html_safe
    end
    column :administrated_recurring_tournaments do |decorated|
      decorated.administrated_recurring_tournaments_admin_links(size: 32).join('<br/>').html_safe
    end
    if current_user.is_root?
      column :sign_in_count
      column :current_sign_in_at
      column :current_sign_in_ip
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all, default: true

  scope :helps, group: :admin_level
  scope :admins, group: :admin_level
  scope :roots, group: :admin_level

  scope :without_discord_user, group: :without
  scope :without_player, group: :without
  scope :without_any_link, group: :without

  filter :name
  filter :sign_in_count
  filter :current_sign_in_at
  filter :current_sign_in_ip
  filter :created_at

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name
      f.input :admin_level,
              collection: user_admin_level_select_collection,
              required: false,
              input_html: { disabled: f.object.is_root? }
      f.input :administrated_teams,
              collection: user_administrated_teams_select_collection,
              input_html: { multiple: true, data: { select2: {} } }
      f.input :administrated_recurring_tournaments,
              collection: user_administrated_recurring_tournaments_select_collection,
              input_html: { multiple: true, data: { select2: {} } }
    end
    f.actions
  end

  permit_params :name, :admin_level,
                administrated_team_ids: [],
                administrated_recurring_tournament_ids: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :admin_level do |decorated|
        decorated.admin_level_status
      end
      row :discord_user do |decorated|
        decorated.discord_user_admin_link
      end
      row :player do |decorated|
        decorated.player_admin_link
      end
      row :created_players do |decorated|
        decorated.created_players_admin_link
      end
      row :administrated_teams do |decorated|
        decorated.administrated_teams_admin_links(size: 32).join('<br/>').html_safe
      end
      row :administrated_recurring_tournaments do |decorated|
        decorated.administrated_recurring_tournaments_admin_links(size: 32).join('<br/>').html_safe
      end
      if current_user.is_root?
        row :sign_in_count
        row :current_sign_in_at
        row :last_sign_in_at
        row :current_sign_in_ip
        row :last_sign_in_ip
      end
      row :created_at
      row :updated_at
    end
  end

  # ---------------------------------------------------------------------------
  # AUTOCOMPLETE
  # ---------------------------------------------------------------------------

  collection_action :autocomplete do
    render json: {
      results: User.by_keyword(params[:term]).map do |user|
        {
          id: user.id,
          text: user.name
        }
      end
    }
  end

end
