class ActiveAdmin::CommunityDecorator < CommunityDecorator
  include ActiveAdmin::BaseDecorator

  decorates :community

  def admin_link(options = {})
    super(options.merge(label: name_with_logo(size: 32)))
  end

  def discord_guilds_admin_links(options = {})
    arbre do
      ul do
        discord_guilds.each do |discord_guild|
          li do
            discord_guild.admin_decorate.admin_link(options)
          end
        end
      end
    end
  end

end
