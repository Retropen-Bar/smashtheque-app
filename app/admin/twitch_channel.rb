ActiveAdmin.register TwitchChannel do

  decorate_with ActiveAdmin::TwitchChannelDecorator

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-video"></i>Chaînes'.html_safe,
       label: '<i class="fab fa-fw fa-twitch"></i>Twitch'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :name do |decorated|
      if decorated.name
        link_to decorated.name, [:admin, decorated.model]
      end
    end
    column :twitch_id do |decorated|
      if decorated.twitch_id
        link_to decorated.twitch_id, [:admin, decorated.model]
      end
    end
    column :slug do |decorated|
      decorated.channel_link(with_icon: true)
    end
    column :profile_image_url do |decorated|
      decorated.profile_image_tag(height: 32)
    end
    column :is_french
    column :related do |decorated|
      decorated.related_admin_link
    end
    column :description
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all, default: true

  scope :related_to_community, group: :related
  scope :related_to_team, group: :related
  scope :related_to_player, group: :related
  scope :related_to_character, group: :related

  filter :twitch_id
  filter :slug
  filter :name
  filter :is_french

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :slug
      f.input :is_french
      related_input(f)
      f.input :description,
              input_html: { rows: 3 }
    end
    f.actions
  end

  permit_params :slug, :is_french, :related_gid, :description

  before_create do |twitch_channel|
    twitch_channel.fetch_twitch_data
  end

  collection_action :related_autocomplete do
    render json: collection.object.related_autocomplete(params[:term])
  end

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :twitch_id
      row :slug do |decorated|
        decorated.channel_link(with_icon: true)
      end
      row :name
      row :is_french
      row :related do |decorated|
        decorated.related_admin_link
      end
      row :description
      row :twitch_description
      row :profile_image_url do |decorated|
        decorated.profile_image_tag(height: 64)
      end
      row :twitch_created_at
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  action_item :fetch_twitch_data,
              only: :show do
    link_to 'Importer les données de twitch', [:fetch_twitch_data, :admin, resource]
  end
  member_action :fetch_twitch_data do
    resource.fetch_twitch_data
    if resource.save
      redirect_to [:admin, resource], notice: 'Import réussi'
    else
      flash[:error] = 'Import échoué'
      redirect_to request.referer
    end
  end

end
