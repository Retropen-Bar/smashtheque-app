ActiveAdmin.register SmashggEvent do

  decorate_with ActiveAdmin::SmashggEventDecorator

  menu parent: '<img src="https://smash.gg/images/gg-app-icon.png" height="16" class="logo"/>smash.gg'.html_safe,
       label: '<i class="fas fa-fw fa-chess"></i>Tournois'.html_safe

  actions :index, :show, :new, :create, :destroy

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :tournament_event, :duo_tournament_event,
           { top1_smashgg_user: { player: { user: :discord_user } } },
           { top2_smashgg_user: { player: { user: :discord_user } } },
           { top3_smashgg_user: { player: { user: :discord_user } } },
           { top4_smashgg_user: { player: { user: :discord_user } } },
           { top5a_smashgg_user: { player: { user: :discord_user } } },
           { top5b_smashgg_user: { player: { user: :discord_user } } },
           { top7a_smashgg_user: { player: { user: :discord_user } } },
           { top7b_smashgg_user: { player: { user: :discord_user } } }

  index do
    selectable_column
    id_column
    column :any_tournament_event do |decorated|
      decorated.any_tournament_event_admin_link
    end
    column 'Tournoi', sortable: :tournament_slug do |decorated|
      decorated.tournament_smashgg_link
    end
    column 'Événement', sortable: :slug do |decorated|
      decorated.smashgg_link
    end
    column :start_at do |decorated|
      decorated.start_at_date
    end
    column :num_entrants
    SmashggEvent::USER_NAMES.each do |user_name|
      column user_name do |decorated|
        decorated.send("#{user_name}_admin_link")
      end
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all, default: true

  scope :with_any_tournament_event, group: :tournament_event
  scope :without_any_tournament_event, group: :tournament_event

  filter :smashgg_id
  filter :tournament_name
  filter :slug
  filter :start_at
  filter :is_online
  filter :num_entrants
  filter :created_at

  batch_action :create_tournament_event, form: -> {
    {
      I18n.t('activerecord.models.recurring_tournament') => RecurringTournament.order(:name).pluck(:name, :id)
    }
  } do |ids, inputs|
    if batch_action_collection.where(id: ids).with_tournament_event.any?
      flash[:error] = 'Certains tournois sont déjà reliés à une édition'
      redirect_to request.referer
    else
      recurring_tournament = RecurringTournament.find(inputs[I18n.t('activerecord.models.recurring_tournament')])
      batch_action_collection.where(id: ids).each do |smashgg_event|
        smashgg_event.fetch_smashgg_data
        smashgg_event.save!
        tournament_event = TournamentEvent.new(
          recurring_tournament: recurring_tournament,
          bracket: smashgg_event
        )
        tournament_event.use_smashgg_event(true)
        tournament_event.save!
      end
      redirect_to request.referer, notice: 'Éditions créées'
    end
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :smashgg_url, placeholder: 'https://smash.gg/...'
    end
    f.actions
  end

  permit_params :smashgg_id, :smashgg_url

  before_create do |smashgg_event|
    smashgg_event.fetch_smashgg_data
  end

  collection_action :bulk_create, method: :post do
    creations_count = 0
    (params[:smashgg_ids] || []).each do |smashgg_id|
      smashgg_event = SmashggEvent.new(smashgg_id: smashgg_id)
      smashgg_event.fetch_smashgg_data
      if smashgg_event.save
        creations_count += 1
      else
        # do not exit on errors
        Rails.logger.debug "SmashggEvent errors: #{smashgg_event.errors.full_messages}"
      end
    end
    redirect_to request.referer, notice: "#{creations_count} imports effectués"
  end

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :smashgg_id
      row :slug
      row 'Tournoi' do |decorated|
        decorated.tournament_smashgg_link
      end
      row 'Événement' do |decorated|
        decorated.smashgg_link
      end
      row :is_online
      row :start_at
      row :num_entrants
      SmashggEvent::USER_NAMES.each do |user_name|
        row user_name do |decorated|
          decorated.send("#{user_name}_admin_link")
        end
      end
      row :tournament_event do |decorated|
        decorated.tournament_event_admin_link
      end
      row :duo_tournament_event do |decorated|
        decorated.duo_tournament_event_admin_link
      end
      row :created_at
      row :updated_at
    end
  end

  action_item :fetch_smashgg_data,
              only: :show do
    link_to 'Importer les données de smash.gg', [:fetch_smashgg_data, :admin, resource]
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

  action_item :create_tournament_event,
              only: :show,
              if: proc { resource.tournament_event.nil? && resource.duo_tournament_event.nil? } do
    dropdown_menu "Créer l'édition", button: { class: 'blue' } do
      item 'Édition 1v1', resource.create_tournament_event_admin_path
      item 'Édition 2v2', resource.create_duo_tournament_event_admin_path
    end
  end

  # ---------------------------------------------------------------------------
  # SEARCH
  # ---------------------------------------------------------------------------

  action_item :lookup, only: :index do
    link_to 'Rechercher sur smash.gg', { action: :lookup }, class: :orange
  end
  collection_action :lookup do
    @name = params[:name]
    @from = params[:from] ? Date.parse(params[:from]) : (Date.today - 1.month)
    @to = params[:to] ? Date.parse(params[:to]) : Date.today
    # add 1 day because we are using dates and not datetimes
    @smashgg_events = SmashggEvent.lookup(name: @name, from: @from, to: @to + 1.day)
  end

end
