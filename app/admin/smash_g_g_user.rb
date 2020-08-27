ActiveAdmin.register SmashGGUser do

  decorate_with SmashGGUserDecorator

  menu parent: '<i class="fas fa-fw fa-project-diagram"></i>Comptes'.html_safe,
       label: proc { image_tag('smashgg-48.png', height: 16, class: 'logo')+'smash.gg' }

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :player

  index do
    selectable_column
    id_column
    column :smashgg_id
    column :gamer_tag do |decorated|
      decorated.full_name(max_height: '32px')
    end
    column :player
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  scope :all
  scope :with_player
  scope :unknown

  filter :smashgg_id
  filter :created_at

  action_item :fetch_unknown,
              only: :index,
              if: proc { SmashGGUser.unknown.any? } do
    link_to 'Compléter', fetch_unknown_admin_smash_gg_users_path, class: 'blue'
  end
  collection_action :fetch_unknown do
    SmashGGUser.fetch_unknown
    redirect_to request.referer, notice: 'Données récupérées'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :smashgg_id
    end
    f.actions
  end

  permit_params :smashgg_id

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :player
      row :smashgg_id
      row :slug do |decorated|
        decorated.smash_gg_link
      end
      row :avatar do |decorated|
        decorated.avatar_tag(max_height: 128)
      end
      row :gamer_tag do |decorated|
        decorated.prefixed_gamer_tag
      end
      row :name
      row :bio
      row :birthday
      row :gender_pronoun
      row :city
      row :country
      row :country_id
      row :state
      row :state_id
      row :banner_url do |decorated|
        decorated.banner_tag(max_height: 64)
      end
      row :twitch_username do |decorated|
        decorated.twitch_link
      end
      row :twitter_username do |decorated|
        decorated.twitter_link
      end
      row :discord_user do |decorated|
        if decorated.discord_user
          decorated.discord_user.decorated.full_name(size: 32)
        else
          decorated.discord_discriminated_username
        end
      end
      row :created_at
      row :updated_at
    end
  end

  action_item :fetch_smashgg_data,
              only: :show do
    link_to 'Importer les données de smash.gg', [:fetch_smashgg_data, :admin, resource]
  end
  member_action :fetch_smashgg_data do
    resource.fetch_smashgg_data
    if resource.save
      redirect_to [:admin, resource], notice: 'Import réussi'
    else
      flash[:error] = 'Import échoué'
      redirect_to request.referer
    end
  end

end
