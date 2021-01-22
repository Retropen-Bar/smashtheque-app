ActiveAdmin.register Duo do

  decorate_with ActiveAdmin::DuoDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-users"></i>Équipes 2v2'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes player1: { user: :discord_user },
           player2: { user: :discord_user }

  index do
    selectable_column
    id_column
    column :name
    column :player1 do |decorated|
      decorated.player1_admin_link
    end
    column :player2 do |decorated|
      decorated.player2_admin_link
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :name

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :name
      player_input f, :player1
      player_input f, :player2
    end
    f.actions
  end

  permit_params :name, :player1_id, :player2_id

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :name
      row :player1 do |decorated|
        decorated.player1_admin_link
      end
      row :player2 do |decorated|
        decorated.player2_admin_link
      end
      row :created_at
      row :updated_at
    end
  end

end
