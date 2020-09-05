class PlayerDecorator < BaseDecorator

  def indicated_name
    classes = []
    if !model.is_accepted? && model.potential_duplicates.any?
      classes << 'txt-error-underline'
    end
    h.content_tag :span, model.name, class: classes
  end

  def name_or_indicated_name
    if model.is_accepted?
      model.name
    else
      indicated_name
    end
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
