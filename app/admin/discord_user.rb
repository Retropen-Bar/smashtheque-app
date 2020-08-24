ActiveAdmin.register DiscordUser do

  decorate_with DiscordUserDecorator

  menu label: '<i class="fab fa-fw fa-discord"></i>Comptes Discord'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :admin_user, :player

  index do
    selectable_column
    id_column
    column :discord_id
    column :username do |decorated|
      decorated.full_name(size: 32)
    end
    column :player
    column :admin_user do |decorated|
      decorated.admin_user_status
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all
  scope :with_admin_user
  scope :unknown

  filter :discord_id
  filter :username
  filter :discriminator
  filter :created_at

  action_item :fetch_unknown,
              only: :index,
              if: proc { DiscordUser.unknown.any? } do
    link_to 'Compléter', fetch_unknown_admin_discord_users_path, class: 'blue'
  end
  collection_action :fetch_unknown do
    DiscordUser.fetch_unknown
    redirect_to request.referer, notice: 'Données récupérées'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :discord_id
    end
    f.actions
  end

  permit_params :discord_id

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :discord_id
      row :avatar do |decorated|
        decorated.avatar_tag
      end
      row :username do |decorated|
        decorated.discriminated_username
      end
      row :created_at
      row :updated_at
    end
  end

  action_item :fetch_discord_data,
              only: :show do
    link_to 'Importer les données de Discord', [:fetch_discord_data, :admin, resource]
  end
  member_action :fetch_discord_data do
    resource.fetch_discord_data
    if resource.save
      redirect_to [:admin, resource], notice: 'Import réussi'
    else
      flash[:error] = 'Import échoué'
      redirect_to request.referer
    end
  end

end
