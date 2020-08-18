ActiveAdmin.register AdminUser do

  decorate_with AdminUserDecorator

  menu label: 'Admins'

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  index do
    selectable_column
    id_column
    column :avatar_url do |decorated|
      decorated.avatar_tag(max_height: '32px')
    end
    column :name
    column :email
    column :discord_username do |decorated|
      decorated.discord_full_username
    end
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  permit_params :email, :password, :password_confirmation

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :email do |decorated|
        decorated.email_link
      end
      row :avatar_url do |decorated|
        decorated.avatar_tag
      end
      row :discord_username
      row :discord_discriminator
      row :created_at
      row :updated_at
    end
  end

end
