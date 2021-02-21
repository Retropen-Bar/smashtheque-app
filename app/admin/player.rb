ActiveAdmin.register Player do

  decorate_with ActiveAdmin::PlayerDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-user"></i>Joueurs'.html_safe,
       parent: '<i class="far fa-fw fa-user"></i>Fiches'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  order_by(:best_reward_level) do |order_clause|
    if order_clause.order == 'desc'
      'best_reward_level1 DESC, best_reward_level2 DESC'
    else
      'best_reward_level1, best_reward_level2'
    end
  end

  includes :characters, :locations,
           teams: [
            :discord_guilds,
            { logo_attachment: :blob }
           ],
           user: :discord_user,
           creator_user: :discord_user,
           best_reward: { image_attachment: :blob }

  index do
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
    column :locations do |decorated|
      decorated.locations_admin_links.join('<br/>').html_safe
    end
    column :rank
    column :points
    column :best_reward, sortable: :best_reward_level do |decorated|
      decorated.best_reward_admin_link({}, class: 'reward-badge-32')
    end
    column :teams do |decorated|
      decorated.teams_admin_links.join('<br/>').html_safe
    end
    column :creator_user do |decorated|
      decorated.creator_user_admin_link(size: 32)
    end
    column :is_accepted
    column :is_banned do |decorated|
      decorated.ban_status
    end
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

  scope :without_user, group: :incomplete
  scope :without_location, group: :incomplete
  scope :without_character, group: :incomplete
  scope :without_smashgg_user, group: :incomplete

  scope :banned, group: :is_banned

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
  filter :is_banned
  filter :rank
  filter :points
  filter :best_reward,
         as: :select,
         collection: proc { Reward.online_1v1.admin_decorate },
         input_html: { multiple: true, data: { select2: {} } }

  action_item :rebuild_all,
              only: :index,
              if: proc { current_user.is_root? } do
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
      resource.creator_user = current_user
      resource
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      user_input f
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
      f.input :locations,
              collection: player_locations_select_collection,
              include_blank: 'Aucune',
              input_html: { multiple: true, data: { select2: { sortable: true, sortedValues: f.object.location_ids } } }
      f.input :teams,
              collection: player_teams_select_collection,
              include_blank: 'Aucune',
              input_html: { multiple: true, data: { select2: { sortable: true, sortedValues: f.object.team_ids } } }
      f.input :is_accepted
      f.input :is_banned
      f.input :ban_details,
              input_html: { rows: 5 }
    end
    f.actions
  end

  permit_params :name, :is_accepted, :user_id,
                :is_banned, :ban_details,
                old_names: [],
                character_ids: [], location_ids: [], team_ids: []

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
      row :locations do |decorated|
        decorated.locations_admin_links.join('<br/>').html_safe
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
      row :rank
      row :points
      row :best_reward do |decorated|
        decorated.best_reward_admin_link
      end
      row :best_rewards do |decorated|
        decorated.best_rewards_admin_links({}, class: 'reward-badge-32').join(' ').html_safe
      end
      row :unique_rewards do |decorated|
        decorated.unique_rewards_admin_links({}, class: 'reward-badge-32').join(' ').html_safe
      end
      row :created_at
      row :updated_at
    end

    if resource.potential_duplicates.any?
      panel 'Doublons potentiels', style: 'margin-top: 50px' do
        table_for resource.potential_duplicates.admin_decorate, i18n: Player do
          column :name do |decorated|
            decorated.admin_link
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
          column :creator_user do |decorated|
            decorated.creator_user_admin_link(size: 32)
          end
          column :is_accepted
          column :created_at do |decorated|
            decorated.created_at_date
          end
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
          row :admin_level do |decorated|
            decorated.admin_level_status
          end
          row :twitter_username do |decorated|
            decorated.twitter_link
          end
          row :discord_user do |decorated|
            decorated.discord_user_admin_link
          end
          row :player do |decorated|
            decorated.player_admin_link
          end
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
    resource.update_attribute :is_accepted, true
    redirect_to request.referer
  end

  action_item :results,
              only: :show do
    link_to 'Résultats', [:results, :admin, resource]
  end

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
  end

  action_item :create_user,
              only: :show,
              if: proc {
                resource.user_id.nil? && resource._potential_user.nil?
              } do
    link_to "Créer l'utilisateur",
            { action: :create_user },
            class: 'blue'
  end
  member_action :create_user do
    resource.return_or_create_user!
    redirect_to request.referer, notice: 'Utilisateur créé'
  end

  # ---------------------------------------------------------------------------
  # RESULTS
  # ---------------------------------------------------------------------------

  member_action :results do
    @player = resource.admin_decorate
    @tournament_events = @player.tournament_events
                                .order(date: :desc)
                                .admin_decorate
    @rewards_counts = @player.rewards_counts
    @rewards_count = @rewards_counts.values.sum
    @tournament_events_count = @tournament_events.count
  end

  # ---------------------------------------------------------------------------
  # AUTOCOMPLETE
  # ---------------------------------------------------------------------------

  collection_action :autocomplete do
    render json: {
      results: Player.by_keyword(params[:term]).map do |player|
        {
          id: player.id,
          text: player.decorate.name_and_old_names
        }
      end
    }
  end

end
