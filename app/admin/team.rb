ActiveAdmin.register Team do

  decorate_with ActiveAdmin::TeamDecorator

  has_paper_trail

  menu label: '<i class="fas fa-fw fa-users"></i>Équipes'.html_safe,
       parent: '<i class="far fa-fw fa-user"></i>Fiches'.html_safe

  # ---------------------------------------------------------------------------
  # INDEX
  # ---------------------------------------------------------------------------

  includes :discord_guilds,
           admins: :discord_user,
           logo_attachment: :blob

  index do
    selectable_column
    id_column
    column :logo do |decorated|
      decorated.logo_image_tag(max_height: 32)
    end
    column :short_name do |decorated|
      link_to decorated.short_name, [:admin, decorated.model]
    end
    column :name do |decorated|
      link_to decorated.name, [:admin, decorated.model]
    end
    column :is_offline
    column :is_online
    column :is_sponsor
    column :players do |decorated|
      decorated.players_admin_link
    end
    column :admins do |decorated|
      decorated.admins_admin_links(size: 32).join('<br/>').html_safe
    end
    column :discord_guilds do |decorated|
      decorated.discord_guilds_admin_links
    end
    column :created_at do |decorated|
      decorated.created_at_date
    end
    actions
  end

  filter :short_name
  filter :name
  filter :is_offline
  filter :is_online
  filter :is_sponsor

  action_item :public, only: :show do
    link_to 'Page publique', resource, class: 'green'
  end

  action_item :rebuild,
              only: :index,
              if: proc { current_user.is_root? } do
    link_to 'Rebuild', [:rebuild, :admin, :teams], class: 'blue'
  end
  collection_action :rebuild do
    RetropenBotScheduler.rebuild_teams
    redirect_to request.referer, notice: 'Demande effectuée'
  end

  # ---------------------------------------------------------------------------
  # FORM
  # ---------------------------------------------------------------------------

  form do |f|
    columns do
      column do
        f.inputs do
          f.input :short_name
          f.input :name
          f.input :logo,
                  as: :file,
                  hint: 'Laissez vide pour ne pas changer',
                  input_html: {
                    accept: 'image/*',
                    data: {
                      previewpanel: 'current-logo'
                    }
                  }
          f.input :roster,
                  as: :file,
                  hint: 'Laissez vide pour ne pas changer',
                  input_html: {
                    accept: 'image/*',
                    data: {
                      previewpanel: 'current-roster'
                    }
                  }
          f.input :is_offline
          f.input :is_online
          f.input :is_sponsor
          users_input f, :admins
          f.input :twitter_username
        end
        f.actions
      end
      column do
        panel 'Logo', id: 'current-logo' do
          f.object.decorate.logo_image_tag
        end
        panel 'Roster', id: 'current-roster' do
          f.object.decorate.roster_image_tag
        end
      end
    end
  end

  permit_params :short_name, :name, :logo, :roster, :twitter_username,
                :is_offline, :is_online, :is_sponsor,
                admin_ids: []

  # ---------------------------------------------------------------------------
  # SHOW
  # ---------------------------------------------------------------------------

  show do
    columns do
      column do
        attributes_table do
          row :short_name
          row :name
          row :logo do |decorated|
            decorated.logo_image_tag(max_height: 64)
          end
          row :is_offline
          row :is_online
          row :is_sponsor
          row :players do |decorated|
            decorated.players_admin_link
          end
          row :admins do |decorated|
            decorated.admins_admin_links(size: 32).join('<br/>').html_safe
          end
          row :discord_guilds do |decorated|
            decorated.discord_guilds_admin_links
          end
          row :twitter_username, &:twitter_link
          row :created_at
          row :updated_at
        end
      end
      column do
        panel 'Roster' do
          resource.roster_image_tag(max_width: '100%')
        end
      end
    end
    active_admin_comments
  end

  action_item :other_actions, only: :show do
    dropdown_menu 'Autres actions' do
      if resource.logo.attached?
        item 'Supprimer le logo', action: :purge_logo
      end
      if resource.roster.attached?
        item 'Supprimer le roster', action: :purge_roster
      end
    end
  end

  member_action :purge_logo do
    resource.logo.purge
    redirect_to request.referer, notice: 'Logo supprimé'
  end

  member_action :purge_roster do
    resource.roster.purge
    redirect_to request.referer, notice: 'Roster supprimé'
  end

end
