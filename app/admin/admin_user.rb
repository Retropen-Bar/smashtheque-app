ActiveAdmin.register AdminUser do

  decorate_with AdminUserDecorator

  menu label: '<i class="fas fa-fw fa-shield-alt"></i>Admins'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :discord_user do |decorated|
      decorated.discord_user_admin_link(size: 32)
    end
    column :level do |decorated|
      decorated.level_status
    end
    column :sign_in_count
    column :current_sign_in_at
    column :current_sign_in_ip
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all, default: true

  scope :helps, group: :level
  scope :admins, group: :level
  scope :roots, group: :level

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
      f.input :discord_user,
              collection: admin_user_discord_user_select_collection,
              input_html: { data: { select2: {} } }
      f.input :level,
              collection: admin_user_level_select_collection,
              input_html: { disabled: f.object.is_root? }
    end
    f.actions
  end

  permit_params :discord_user_id, :level

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :discord_user do |decorated|
        decorated.discord_user_admin_link(size: 32)
      end
      row :level do |decorated|
        decorated.level_status
      end
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :created_at
      row :updated_at
    end
  end

end
