module ActiveAdmin
  class CharacterDecorator < CharacterDecorator
    include ActiveAdmin::BaseDecorator

    decorates :character

    def admin_link(options = {})
      super(options.merge(label: options[:label] || emoji_and_name(max_height: '32px')))
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

    def admin_emoji_link(options = {})
      label = emoji_image_tag(max_height: '24px')
      admin_link(options.merge(label: label))
    end

    def players_admin_path
      admin_players_path(q: { characters_players_character_id_in: [model.id] })
    end

    def players_admin_link
      h.link_to players_count, players_admin_path
    end

    def colored_background_color
      return nil if model.background_color.blank?

      h.tag.span model.background_color, style: "color: #{model.background_color}"
    end
  end
end
