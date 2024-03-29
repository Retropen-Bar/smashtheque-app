ActiveAdmin.register YouTubeChannel do

  decorate_with ActiveAdmin::YouTubeChannelDecorator

  has_paper_trail

  menu parent: '<i class="fas fa-fw fa-video"></i>Chaînes'.html_safe,
       label: '<i class="fab fa-fw fa-youtube"></i>YouTube'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :name do |decorated|
      link_to decorated.name, [:admin, decorated.model]
    end
    column :url do |decorated|
      decorated.channel_link(with_icon: true)
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

  filter :name
  filter :url
  filter :is_french
  filter :description

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :name
      f.input :url
      f.input :is_french
      related_input(f)
      f.input :description,
              input_html: { rows: 3 }
    end
    f.actions
  end

  permit_params :name, :url, :is_french, :related_gid, :description

  collection_action :related_autocomplete do
    render json: collection.object.related_autocomplete(params[:term])
  end

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :url do |decorated|
        decorated.channel_link(with_icon: true)
      end
      row :is_french
      row :related do |decorated|
        decorated.related_admin_link
      end
      row :description
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
