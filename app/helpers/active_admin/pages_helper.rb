module ActiveAdmin
  module PagesHelper
    def page_parent_select_collection
      Page.orphan.order('LOWER(name)').pluck(:name, :id)
    end
  end
end
