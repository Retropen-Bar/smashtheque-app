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
          f.input :website_url
          f.input :creation_year
          f.input :is_recruiting
          f.input :recruiting_details, as: :action_text
          f.input :description, as: :action_text
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
                :website_url, :creation_year, :is_recruiting, :recruiting_details, :description,
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
          row :website_url, &:website_link
          row :creation_year
          row :is_recruiting
          row :recruiting_details, &:formatted_recruiting_details
          row :description, &:formatted_description
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
