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

  action_item :rebuild,
              only: :index,
              if: proc { current_admin_user.is_root? } do
    link_to 'Rebuild', [:rebuild, :admin, :you_tube_channels], class: 'blue'
  end
  collection_action :rebuild do
    RetropenBotScheduler.rebuild_youtube
    redirect_to request.referer, notice: 'Demande effectuée'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :username
      f.input :is_french
      related_input(f)
      f.input :description,
              input_html: { rows: 3 }
    end
    f.actions
  end

  permit_params :username, :is_french, :related_gid, :description

  collection_action :related_autocomplete do
    render json: collection.object.related_autocomplete(params[:term])
  end

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
