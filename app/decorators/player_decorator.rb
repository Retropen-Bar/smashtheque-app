class PlayerDecorator < BaseDecorator

  def autocomplete_name
    model.name
  end

  def listing_name
    model.name
  end

  def icon_class
    :user
  end

  def as_autocomplete_result
    h.content_tag :div, class: :player do
      h.content_tag :div, class: :name do
        name
      end
    end
  end

end
