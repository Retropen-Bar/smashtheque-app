class DuoDecorator < BaseDecorator
  include HasTrackRecordsDecorator

  def name_with_player_names
    "#{name} : #{player1_name} & #{player2_name}"
  end

  def avatars_tag(size)
    h.tag.div class: 'avatars' do
      (
        player1&.decorate&.avatar_tag(size)
      ) + (
        player2&.decorate&.avatar_tag(size)
      )
    end
  end

  def name_with_avatars(size: nil)
    [
      avatars_tag(size),
      name
    ].join('&nbsp;').html_safe
  end

  def link(options = {})
    avatar_size = options.delete(:avatar_size) || 32
    super({ label: name_with_avatars(size: avatar_size) }.merge(options))
  end

  def icon_class
    'user-friends'
  end

  def as_autocomplete_result
    h.tag.div class: :duo do
      h.tag.div class: :name do
        name
      end
    end
  end
end
