ActiveAdmin.register DiscordGuildAdmin do

  decorate_with ActiveAdmin::DiscordGuildAdminDecorator

  menu parent: '<i class="fab fa-fw fa-discord"></i>Discord'.html_safe,
       label: 'Admins'

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :discord_guild, :discord_user

  index do
    selectable_column
    id_column
    column :discord_guild do |decorated|
      decorated.discord_guild_admin_link
    end
    column :discord_user do |decorated|
      decorated.discord_user_admin_link(size: 32)
    end
    column :role
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :discord_guild
  filter :discord_user

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    f.inputs do
      f.input :discord_guild,
              collection: discord_guild_admin_discord_guild_select_collection,
              input_html: { data: { select2: {} } }
      f.input :discord_user,
              collection: discord_guild_admin_discord_user_select_collection,
              input_html: { data: { select2: {} } }
      f.input :role
    end
    f.actions
  end

  permit_params :discord_guild_id, :discord_user_id, :role

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    attributes_table do
      row :discord_guild do |decorated|
        decorated.discord_guild_admin_link
      end
      row :discord_user do |decorated|
        decorated.discord_user_admin_link(size: 32)
      end
      row :role
      row :created_at
      row :updated_at
    end
  end

end
