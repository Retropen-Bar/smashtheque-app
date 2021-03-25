class ActiveAdmin::PageDecorator < PageDecorator
  include ActiveAdmin::BaseDecorator

  decorates :page

  def parent_admin_link(options = {})
    parent&.admin_decorate&.admin_link(options)
  end

  def children_admin_links(options = {})
    children.map do |page|
      page.admin_decorate.admin_link(options.clone)
    end
  end

end
