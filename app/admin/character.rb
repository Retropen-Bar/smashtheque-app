ActiveAdmin.register Character do

  decorate_with ActiveAdmin::CharacterDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-gamepad"></i>Persos'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :name do |decorated|
      decorated.admin_link
    end
    column :players do |decorated|
      decorated.players_admin_link
    end
    column :background_color do |decorated|
      decorated.colored_background_color
    end
    column :background_image do |decorated|
      decorated.background_image_tag(max_width: 64, max_height: 64)
    end
    column :discord_guilds do |decorated|
      decorated.discord_guilds_admin_links
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :name

  scope :all, default: true
  scope :without_background

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :emoji
      f.input :icon
      f.input :name
      f.input :background_color,
              as: :string,
              input_html: { data: { colorpicker: {} } }
      f.input :background_image
      f.input :background_size
    end
    f.actions
  end

  permit_params :icon, :name, :emoji,
                :background_color, :background_image, :background_size

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :emoji do |decorated|
        decorated.emoji_image_tag
      end
      row :icon
      row :name
      row :background_color do |decorated|
        decorated.colored_background_color
      end
      row :background_image do |decorated|
        decorated.background_image_tag(max_width: 64, max_height: 64)
      end
      row :background_size do |decorated|
        decorated.background_size_display
      end
      row :players do |decorated|
        decorated.players_admin_link
      end
      row :discord_guilds do |decorated|
        decorated.discord_guilds_admin_links
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
  end

  action_item :rebuild,
              only: :show,
              if: proc { current_admin_user.is_root? } do
    link_to 'Rebuild', [:rebuild, :admin, resource], class: 'blue'
  end
  member_action :rebuild do
    RetropenBotScheduler.rebuild_chars_for_character resource
    redirect_to request.referer, notice: 'Demande effectuée'
  end

end
