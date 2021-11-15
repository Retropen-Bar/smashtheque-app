ActiveAdmin.register Character do
  decorate_with ActiveAdmin::CharacterDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-gamepad"></i>Persos'.html_safe,
       parent: '<i class="fas fa-fw fa-cog"></i>Configuration'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :discord_guilds

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
      f.input :other_names,
              multiple: true,
              collection: f.object.other_names,
              input_html: {
                data: {
                  select2: {
                    tags: true,
                    tokenSeparators: [',']
                  }
                }
              }
      f.input :origin
      f.input :background_color,
              as: :string,
              input_html: {
                rows: 5,
                data: { colorpicker: {} }
              }
      f.input :background_image
      f.input :background_size
      f.input :nintendo_url
      f.input :ultimateframedata_url
      f.input :smashprotips_url
    end
    f.actions
  end

  permit_params :icon, :name, :emoji,
                :origin, :background_color, :background_image, :background_size,
                :nintendo_url, :ultimateframedata_url, :smashprotips_url,
                other_names: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :emoji, &:emoji_image_tag
      row :icon
      row :name
      row :other_names
      row :origin
      row :background_color, &:colored_background_color
      row :background_image do |decorated|
        decorated.background_image_tag(max_width: 64, max_height: 64)
      end
      row :background_size, &:background_size_display
      row :players, &:players_admin_link
      row :discord_guilds, &:discord_guilds_admin_links
      row :nintendo_url, &:nintendo_link
      row :ultimateframedata_url, &:ultimateframedata_link
      row :smashprotips_url, &:smashprotips_link
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
  end
end
