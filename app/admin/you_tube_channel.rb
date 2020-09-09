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
    column :username do |decorated|
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

  filter :username
  filter :is_french

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :username
      f.input :is_french
      f.input :related_gid,
              as: :select,
              collection: youtube_channel_related_global_select_collection,
              input_html: { data: { select2: {} } }
      f.input :description
    end
    f.actions
  end

  permit_params :username, :is_french, :related_gid, :description

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :username do |decorated|
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
