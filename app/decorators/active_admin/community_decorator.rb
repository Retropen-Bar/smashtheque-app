module ActiveAdmin
  class CommunityDecorator < CommunityDecorator
    include ActiveAdmin::BaseDecorator

    decorates :community

    def admin_link(options = {})
      super(options.merge(label: name_with_logo(max_height: 32)))
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

    def admins_admin_links(options = {})
      model.admins.map do |user|
        user.admin_decorate.admin_link(options)
      end
    end

    def ranking_link(options = {})
      return nil if ranking_url.blank?

      h.link_to ranking_url, { target: '_blank', rel: :noopener }.merge(options) do
        (
          h.fas_icon_tag 'link'
        ) + ' ' + (
          ranking_url
        )
      end
    end

    def parent_admin_link(options = {})
      parent&.admin_decorate&.admin_link(options)
    end

    def children_admin_links(options = {})
      children.map do |community|
        community.admin_decorate.admin_link(options.clone)
      end
    end
  end
end
