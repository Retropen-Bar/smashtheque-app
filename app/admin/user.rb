ActiveAdmin.register User do

  decorate_with ActiveAdmin::UserDecorator

  menu label: '<i class="fas fa-fw fa-user-secret"></i>Utilisateurs'.html_safe,
       parent: '<i class="far fa-fw fa-user"></i>Fiches'.html_safe

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
    column :is_caster
    column :is_coach
    column :is_graphic_designer
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

  scope :casters, group: :actors
  scope :coaches, group: :actors
  scope :graphic_designers, group: :actors

  filter :name
  filter :sign_in_count
  filter :current_sign_in_at
  filter :current_sign_in_ip
  filter :created_at

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    render 'admin/shared/google_places_api'
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name
      f.input :admin_level,
              collection: user_admin_level_select_collection,
              required: false,
              input_html: { disabled: f.object.is_root? }
      f.input :twitter_username
      f.input :administrated_teams,
              collection: user_administrated_teams_select_collection,
              input_html: { multiple: true, data: { select2: {} } }
      f.input :administrated_recurring_tournaments,
              collection: user_administrated_recurring_tournaments_select_collection,
              input_html: { multiple: true, data: { select2: {} } }
      address_input f, prefix: 'main_'
      address_input f, prefix: 'secondary_'

      f.input :is_caster
      f.input :is_coach, input_html: { data: { toggle: '.coaching-fields' } }
      f.input :coaching_url, wrapper_html: { class: 'coaching-fields' }
      f.input :coaching_details, wrapper_html: { class: 'coaching-fields' }
      f.input :is_graphic_designer, input_html: { data: { toggle: '.graphic-designer-fields' } }
      f.input :graphic_designer_details, wrapper_html: { class: 'graphic-designer-fields' }
      f.input :is_available_graphic_designer, wrapper_html: { class: 'graphic-designer-fields' }
    end
    f.actions
  end

  permit_params :name, :admin_level, :twitter_username,
                :is_caster,
                :is_coach, :coaching_url, :coaching_details,
                :is_graphic_designer, :graphic_designer_details,
                :is_available_graphic_designer,
                :main_address, :main_latitude, :main_longitude, :main_locality,
                :secondary_address, :secondary_latitude, :secondary_longitude, :secondary_locality,
                administrated_team_ids: [],
                administrated_recurring_tournament_ids: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    columns do
      column do
        attributes_table do
          row :name
          row :admin_level do |decorated|
            decorated.admin_level_status
          end
          row :twitter_username, &:twitter_link
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
          row :main_address do |decorated|
            decorated.main_address_with_coordinates
          end
          row :main_locality
          row :secondary_address do |decorated|
            decorated.secondary_address_with_coordinates
          end
          row :secondary_locality
          row :is_caster
          row :is_coach
          row :coaching_url
          row :coaching_details
          row :is_graphic_designer
          row :graphic_designer_details
          row :is_available_graphic_designer
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
      column do
        if resource.main_address || resource.secondary_address
          user_addresses_map(resource)
        end
      end
    end

    if resource._potential_discord_user
      panel 'Potentiel compte Discord', style: 'margin-top: 50px' do
        attributes_table_for resource._potential_discord_user.admin_decorate do
          row 'Action' do |decorated|
            semantic_form_for([:admin, resource._potential_discord_user]) do |f|
              (
                f.input :user_id,
                        as: :hidden,
                        input_html: { value: resource.id }
              ) + (
                f.submit 'Relier à ce compte', class: 'button-auto green'
              )
            end
          end
          row :discord_id
          row :avatar do |decorated|
            decorated.avatar_tag
          end
          row :username do |decorated|
            decorated.discriminated_username
          end
          row :user do |decorated|
            decorated.user_admin_link
          end
          row :administrated_discord_guilds do |decorated|
            decorated.administrated_discord_guilds_admin_links(size: 32).join('<br/>').html_safe
          end
          row :created_at
          row :updated_at
        end
      end
    end
  end

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
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
