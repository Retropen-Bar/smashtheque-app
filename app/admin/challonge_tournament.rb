ActiveAdmin.register ChallongeTournament do

  decorate_with ActiveAdmin::ChallongeTournamentDecorator

  menu parent: '<img src="https://assets.challonge.com/assets/challonge_fireball_orange-a973ff3b12c34c780fc21313ec71aada3b9b779cbd3a62769e9199ce08395692.svg" height="16" class="logo"/>Challonge'.html_safe,
       label: 'Tournois'

  actions :index, :show, :new, :create, :destroy

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :tournament_event

  index do
    selectable_column
    id_column
    column 'Tournoi', sortable: :slug do |decorated|
      decorated.challonge_link
    end
    column :start_at
    column :participants_count
    ChallongeTournament::PARTICIPANT_NAMES.each do |participant_name|
      column participant_name
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

  filter :challonge_id
  filter :slug
  filter :name
  filter :start_at
  filter :participants_count
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
      batch_action_collection.where(id: ids).each do |challonge_tournament|
        challonge_tournament.fetch_challonge_data
        challonge_tournament.save!
        tournament_event = TournamentEvent.new(
          recurring_tournament: recurring_tournament,
          challonge_tournament: challonge_tournament
        )
        tournament_event.use_challonge_tournament(true)
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
      f.input :challonge_url, placeholder: 'https://challonge.com/...'
    end
    f.actions
  end

  permit_params :challonge_id, :challonge_url

  before_create do |challonge_tournament|
    challonge_tournament.fetch_challonge_data
  end

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :challonge_id
      row :slug
      row 'Tournoi' do |decorated|
        decorated.challonge_link
      end
      row :start_at
      row :participants_count
      ChallongeTournament::PARTICIPANT_NAMES.each do |participant_name|
        row participant_name
      end
      row :tournament_event do |decorated|
        decorated.tournament_event_admin_link
      end
      row :created_at
      row :updated_at
    end
  end

  action_item :fetch_challonge_data,
              only: :show do
    link_to 'Importer les données de Challonge', [:fetch_challonge_data, :admin, resource]
  end
  member_action :fetch_challonge_data do
    resource.fetch_challonge_data
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
    link_to 'Rechercher sur Challonge', { action: :lookup }, class: :orange
  end
  collection_action :lookup do
    @name = params[:name]
    @from = params[:from] ? Date.parse(params[:from]) : (Date.today - 1.month)
    @to = params[:to] ? Date.parse(params[:to]) : Date.today
    # add 1 day because we are using dates and not datetimes
    @challonge_tournaments = ChallongeTournament.lookup(
      name: @name,
      from: @from,
      to: @to + 1.day
    )
  end

end
