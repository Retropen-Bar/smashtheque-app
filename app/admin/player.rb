ActiveAdmin.register Player do
  decorate_with ActiveAdmin::PlayerDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-user"></i>Joueurs'.html_safe,
       parent: '<i class="far fa-fw fa-user"></i>Fiches'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  controller do
    def scoped_collection
      super.with_track_records_online_all_time.with_track_records_offline_all_time
    end
  end

  order_by(:points_online_all_time) do |order_clause|
    if order_clause.order == 'desc'
      'points_online_all_time DESC NULLS LAST'
    else
      'points_online_all_time ASC NULLS FIRST'
    end
  end

  order_by(:points_offline_all_time) do |order_clause|
    if order_clause.order == 'desc'
      'points_offline_all_time DESC NULLS LAST'
    else
      'points_offline_all_time ASC NULLS FIRST'
    end
  end

  includes :characters,
           teams: [
             :discord_guilds,
             { logo_attachment: :blob }
           ],
           user: :discord_user,
           creator_user: :discord_user

  index do
    div do
      render 'index_top'
    end

    selectable_column
    id_column
    column :name do |decorated|
      link_to decorated.name_or_indicated_name, [:admin, decorated.model]
    end
    column :user do |decorated|
      decorated.user_admin_link(size: 32)
    end
    column :characters do |decorated|
      decorated.characters_admin_links.join(' ').html_safe
    end
    column :teams do |decorated|
      decorated.teams_admin_short_links.join('<br/>').html_safe
    end
    column "<img src=\"https://cdn.discordapp.com/emojis/#{RetropenBot::EMOJI_POINTS_ONLINE}.png?size=16\"/>".html_safe,
           sortable: :points_online_all_time,
           &:points_online_all_time
    column "<img src=\"https://cdn.discordapp.com/emojis/#{RetropenBot::EMOJI_POINTS_OFFLINE}.png?size=16\"/>".html_safe,
           sortable: :points_offline_all_time,
           &:points_offline_all_time
    column :creator_user do |decorated|
      decorated.creator_user_admin_link(size: 32)
    end
    column :is_accepted
    column :is_banned, &:ban_status
    column :created_at, &:created_at_date
    actions dropdown: true do |decorated|
      if !decorated.is_accepted? && !decorated.model.potential_duplicates.any?
        item 'Valider', accept_admin_player_path(decorated.model), class: 'green'
      end
    end
  end

  scope :all, default: true

  scope :accepted, group: :is_accepted
  scope :to_be_accepted, group: :is_accepted

  scope :without_user, group: :incomplete
  scope :without_character, group: :incomplete
  scope :without_smashgg_user, group: :incomplete

  scope :banned, group: :is_banned

  filter :name
  filter :characters,
         as: :select,
         collection: proc { player_characters_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :teams,
         as: :select,
         collection: proc { player_teams_select_collection },
         input_html: { multiple: true, data: { select2: {} } }
  filter :is_accepted
  filter :is_banned

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  controller do
    def build_new_resource
      resource = super
      resource.creator_user = current_user
      resource
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    columns do
      column do
        f.inputs 'Joueur' do
          f.input :name
          f.input :old_names,
                  multiple: true,
                  collection: f.object.old_names,
                  input_html: {
                    data: {
                      select2: {
                        tags: true,
                        tokenSeparators: [',']
                      }
                    }
                  }
          f.input :characters,
                  collection: player_characters_select_collection,
                  input_html: { multiple: true, data: { select2: { sortable: true, sortedValues: f.object.character_ids } } }
          f.input :teams,
                  collection: player_teams_select_collection,
                  include_blank: 'Aucune',
                  input_html: { multiple: true, data: { select2: { sortable: true, sortedValues: f.object.team_ids } } }
        end
      end
      column do
        f.inputs 'Compte Discord' do
          if f.object.discord_user
            div class: 'existing-value' do
              f.object.discord_user.admin_decorate.admin_link
            end
          end
          f.input :discord_id,
                  label: 'ID du compte'
        end
        f.inputs 'Compte(s) smash.gg' do
          f.object.smashgg_users.each do |smashgg_user|
            div class: 'existing-value' do
              smashgg_user.admin_decorate.admin_link
            end
          end
          f.input :smashgg_url,
                  label: 'URL du profil à ajouter',
                  input_html: { value: '' }
        end
      end
    end
    f.inputs 'Smashthèque' do
      f.input :is_accepted
      f.input :is_banned
      f.input :ban_details,
              input_html: { rows: 5 }
    end
    f.actions
  end

  permit_params :name, :is_accepted, :discord_id, :smashgg_url,
                :is_banned, :ban_details,
                old_names: [],
                character_ids: [], team_ids: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :old_names do |decorated|
        decorated.old_names_list
      end
      row :user do |decorated|
        decorated.user_admin_link(size: 32)
      end
      row :smashgg_users do |decorated|
        decorated.smashgg_users_admin_links(size: 32).join('<br/>').html_safe
      end
      row :characters do |decorated|
        decorated.characters_admin_links.join('<br/>').html_safe
      end
      row :teams do |decorated|
        decorated.teams_admin_links.join('<br/>').html_safe
      end
      row :creator_user do |decorated|
        decorated.creator_user_admin_link(size: 32)
      end
      row :is_accepted
      row :is_banned
      row :ban_details
      row :rank_online_all_time
      row :rank_offline_all_time
      row :points_online_all_time
      row :points_offline_all_time

      # row :best_reward do |decorated|
      #   decorated.best_reward_admin_link
      # end
      # row :best_rewards do |decorated|
      #   decorated.best_rewards_admin_links({}, class: 'reward-badge-32').join(' ').html_safe
      # end
      # row :unique_rewards do |decorated|
      #   decorated.unique_rewards_admin_links({}, class: 'reward-badge-32').join(' ').html_safe
      # end
      row :created_at
      row :updated_at
    end

    if resource.potential_duplicates.any?
      panel 'Doublons potentiels', style: 'margin-top: 50px' do
        table_for resource.potential_duplicates.admin_decorate, i18n: Player do
          column :name, &:admin_link
          column :characters do |decorated|
            decorated.characters_admin_links.join(' ').html_safe
          end
          column :teams do |decorated|
            decorated.teams_admin_links.join('<br/>').html_safe
          end
          column :creator_user do |decorated|
            decorated.creator_user_admin_link(size: 32)
          end
          column :is_accepted
          column :created_at, &:created_at_date
        end
      end
    end

    if resource._potential_user
      panel 'Utilisateur potentiel', style: 'margin-top: 50px' do
        attributes_table_for resource._potential_user.admin_decorate do
          row 'Action' do |decorated|
            semantic_form_for([:admin, resource]) do |f|
              (
                f.input :user_id,
                        as: :hidden,
                        input_html: { value: decorated.model.id }
              ) + (
                f.submit 'Relier à cet utilisateur', class: 'button-auto green'
              )
            end
          end
          row :name
          row :admin_level, &:admin_level_status
          row :twitter_username, &:twitter_link
          row :discord_user, &:discord_user_admin_link
          row :player, &:player_admin_link
          row :administrated_teams do |decorated|
            decorated.administrated_teams_admin_links(size: 32).join('<br/>').html_safe
          end
          row :administrated_recurring_tournaments do |decorated|
            decorated.administrated_recurring_tournaments_admin_links(size: 32).join('<br/>').html_safe
          end
          row :is_caster
          row :is_coach
          row :coaching_url
          row :coaching_details
          row :is_graphic_designer
          row :graphic_designer_details
          row :is_available_graphic_designer
          row :created_at
          row :updated_at
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
    resource.is_accepted = true
    if resource.save
      redirect_to request.referer, notice: 'Joueur validé'
    else
      Rails.logger.error "Player errors: #{resource.errors.full_messages}"
      flash[:error] = 'Impossible de valider ce joueur'
      redirect_to request.referer
    end
  end

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
  end

  action_item :other_actions, only: :show do
    dropdown_menu 'Autres actions' do
      if resource.user_id.nil? && resource._potential_user.nil?
        item "Créer l'utilisateur", action: :create_user
      end
      item 'Voir les résultats', [:results, :admin, resource]
      if resource.tournament_events.any? && can?(:move_results, resource)
        item 'Transférer les résultats', action: :move_results
      end
    end
  end

  member_action :create_user do
    resource.return_or_create_user!
    redirect_to request.referer, notice: 'Utilisateur créé'
  end

  member_action :move_results do
    @player = resource
    render 'move_results'
  end

  member_action :do_move_results, method: :post do
    other_player_id = params[:player][:id]
    resource.move_results_to!(other_player_id)
    redirect_to [:admin, resource], notice: 'Transfert effectué'
  end

  # ---------------------------------------------------------------------------
  # RESULTS
  # ---------------------------------------------------------------------------

  member_action :results do
    @resource = resource.admin_decorate
    @events = @resource.tournament_events.order(date: :desc).admin_decorate
    @all_online_rewards = Reward.online_1v1
    @all_offline_rewards = Reward.offline_1v1
    @online_rewards_counts = @player.rewards_counts(is_online: true)
    @offline_rewards_counts = @player.rewards_counts(is_online: false)
    @rewards_count = @online_rewards_counts.values.sum + @offline_rewards_counts.values.sum
    @events_count = @events.count
    render 'admin/shared/results'
  end

  # ---------------------------------------------------------------------------
  # SUGGESTIONS
  # ---------------------------------------------------------------------------

  action_item :potential_users, only: :index do
    link_to 'Utilisateurs potentiels', { action: :potential_users }, class: :blue
  end

  collection_action :potential_users do
    @players = Player.with_potential_user.page(params[:page] || 1).per(50)
  end
end
