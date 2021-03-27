class ActiveAdmin::LocationDecorator < LocationDecorator
  include ActiveAdmin::BaseDecorator

  decorates :location

  def admin_link(options = {})
    super(options.merge(label: full_name))
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

  def players_admin_path
    # TODO: fix this
    # admin_players_path(q: {locations_players_location_id_in: [model.id]})
    '#'
  end

  def players_admin_link
    h.link_to players_count, players_admin_path
  end

end
