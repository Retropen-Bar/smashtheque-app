ActiveAdmin.register BraacketTournament do

  decorate_with ActiveAdmin::BraacketTournamentDecorator

  menu parent: '<img src="https://braacket.com/favicon.ico" height="16" class="logo"/>Braacket'.html_safe,
       label: '<i class="fas fa-fw fa-chess"></i>Tournois'.html_safe

  actions :index, :show, :new, :create, :destroy

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :tournament_event, :duo_tournament_event

  index do
    selectable_column
    id_column
    column :any_tournament_event do |decorated|
      decorated.any_tournament_event_admin_link
    end
    column 'Tournoi', sortable: :slug do |decorated|
      decorated.braacket_link
    end
    column :start_at do |decorated|
      decorated.start_at_date
    end
    column :participants_count
    BraacketTournament::PARTICIPANT_NAMES.each do |participant_name|
      column participant_name
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all, default: true

  scope :with_any_tournament_event, group: :tournament_event
  scope :without_any_tournament_event, group: :tournament_event

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
      batch_action_collection.where(id: ids).each do |braacket_tournament|
        braacket_tournament.fetch_braacket_data
        braacket_tournament.save!
        tournament_event = TournamentEvent.new(
          recurring_tournament: recurring_tournament,
          bracket: braacket_tournament
        )
        tournament_event.use_braacket_tournament(true)
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
      f.input :braacket_url, placeholder: 'https://braacket.com/...'
    end
    f.actions
  end

  permit_params :braacket_id, :braacket_url

  before_create do |braacket_tournament|
    braacket_tournament.fetch_braacket_data
  end

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :slug
      row 'Tournoi' do |decorated|
        decorated.braacket_link
      end
      row :start_at
      row :participants_count
      BraacketTournament::PARTICIPANT_NAMES.each do |participant_name|
        row participant_name
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

  action_item :create_tournament_event,
              only: :show,
              if: proc { resource.tournament_event.nil? && resource.duo_tournament_event.nil? } do
    dropdown_menu "Créer l'édition", button: { class: 'blue' } do
      item 'Édition 1v1', resource.create_tournament_event_admin_path
      item 'Édition 2v2', resource.create_duo_tournament_event_admin_path
    end
  end

  action_item :fetch_braacket_data,
              only: :show do
    link_to 'Importer les données de Braacket', [:fetch_braacket_data, :admin, resource]
  end
  member_action :fetch_braacket_data do
    resource.fetch_braacket_data
    if resource.save
      redirect_to [:admin, resource], notice: 'Import réussi'
    else
      flash[:error] = 'Import échoué'
      redirect_to request.referer
    end
  end

end
