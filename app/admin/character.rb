ActiveAdmin.register Character do

  decorate_with CharacterDecorator

  menu label: 'Persos'

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :head_icon_url do |decorated|
      decorated.head_icon_tag(max_height: '32px')
    end
    column :icon
    column :name
    column :emoji do |decorated|
      decorated.emoji_code
    end
    column :players do |decorated|
      decorated.players_link
    end
    column :created_at
    actions
  end

  filter :name

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :head_icon_url
      f.input :icon
      f.input :name
      f.input :emoji
    end
    f.actions
  end

  permit_params :icon, :name, :head_icon_url, :emoji

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :head_icon_url do |decorated|
        decorated.head_icon_tag
      end
      row :icon
      row :name
      row :emoji do |decorated|
        decorated.emoji_code
      end
      row :players do |decorated|
        decorated.players_link
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

end
