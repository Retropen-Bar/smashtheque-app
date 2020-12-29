ActiveAdmin.register SmashggEvent do

  decorate_with ActiveAdmin::SmashggEventDecorator

  menu parent: '<img src="https://smash.gg/images/gg-app-icon.png" height="16" class="logo"/>smash.gg'.html_safe,
       label: 'Tournois'

  actions :index, :show, :delete

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :tournament_event

  index do
    selectable_column
    id_column
    column :smashgg_id
    column :slug do |decorated|
      decorated.smashgg_link
    end
    column :tournament_name do |decorated|
      decorated.full_name
    end
    column :is_online
    column :starts_at
    column :num_entrants
    column :tournament_event do |decorated|
      decorated.tournament_event_admin_link
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :smashgg_id
  filter :tournament_name
  filter :slug
  filter :starts_at
  filter :is_online
  filter :num_entrants
  filter :created_at

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :smashgg_id
      row :slug do |decorated|
        decorated.smashgg_link
      end
      row :tournament_name
      row :name
      row :is_online
      row :starts_at
      row :num_entrants
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

end
