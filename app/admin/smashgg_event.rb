ActiveAdmin.register SmashggEvent do

  decorate_with ActiveAdmin::SmashggEventDecorator

  menu parent: '<img src="https://smash.gg/images/gg-app-icon.png" height="16" class="logo"/>smash.gg'.html_safe,
       label: 'Tournois'

  actions :index, :show, :new, :create, :delete

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :tournament_event

  index do
    selectable_column
    id_column
    column 'Tournoi', sortable: :tournament_slug do |decorated|
      decorated.tournament_smashgg_link
    end
    column 'Événement', sortable: :slug do |decorated|
      decorated.smashgg_link
    end
    column :start_at
    column :num_entrants
    SmashggEvent::USER_NAMES.each do |user_name|
      column user_name do |decorated|
        decorated.send("#{user_name}_admin_link")
      end
    end
    column :tournament_event do |decorated|
      decorated.tournament_event_admin_link
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all, default: true

  scope :with_tournament_event, group: :tournament_event
  scope :without_tournament_event, group: :tournament_event

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
          smashgg_event: smashgg_event
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
