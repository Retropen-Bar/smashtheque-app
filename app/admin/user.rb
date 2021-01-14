ActiveAdmin.register User do

  decorate_with ActiveAdmin::UserDecorator

  menu label: '<i class="fas fa-fw fa-user-secret"></i>Utilisateurs'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :name do |decorated|
      decorated.admin_link(size: 32)
    end
    column :discord_user do |decorated|
      decorated.discord_user_admin_link(size: 32)
    end
    column :admin_level do |decorated|
      decorated.admin_level_status
    end
    if current_user.is_root?
      column :sign_in_count
      column :current_sign_in_at
      column :current_sign_in_ip
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all, default: true

  scope :lambda, group: :admin_level
  scope :helps, group: :admin_level
  scope :admins, group: :admin_level
  scope :roots, group: :admin_level

  filter :name
  filter :sign_in_count
  filter :current_sign_in_at
  filter :current_sign_in_ip
  filter :created_at

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name
      discord_user_input f
      f.input :admin_level,
              collection: user_admin_level_select_collection,
              required: false,
              input_html: { disabled: f.object.is_root? }
    end
    f.actions
  end

  permit_params :name, :discord_user_id, :admin_level

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :discord_user do |decorated|
        decorated.discord_user_admin_link(size: 32)
      end
      row :admin_level do |decorated|
        decorated.admin_level_status
      end
      if current_user.is_root?
        row :sign_in_count
        row :current_sign_in_at
        row :last_sign_in_at
        row :current_sign_in_ip
        row :last_sign_in_ip
      end
      row :created_at
      row :updated_at
    end
  end

end
