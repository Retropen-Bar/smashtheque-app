class PlayerDecorator < BaseDecorator

  def autocomplete_name
    model.name
  end

  def listing_name
    model.name
  end

  def name_with_avatar(size: nil)
    [
      if model.discord_user
        model.discord_user.decorate.avatar_tag(size)
      else
        default_avatar(size)
      end,
      name
    ].join('&nbsp;').html_safe
  end

  def default_avatar(size)
    h.image_tag 'default-avatar.jpg', width: size, class: :avatar
  end

  def ban_status
    if model.is_banned?
      h.content_tag :span,
                    'oui',
                    class: 'status_tag yes',
                    title: model.ban_details,
                    data: { tooltip: {} }
    else
      arbre do
        status_tag :no
      end
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
