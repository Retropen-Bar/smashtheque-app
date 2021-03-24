module ActiveAdmin::PagesHelper

  def page_parent_select_collection
    Page.orphan.order("LOWER(name)").map do |page|
      [
        page.name,
        page.id
      ]
    end
  end

end
