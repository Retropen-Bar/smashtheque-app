class CharacterDecorator < BaseDecorator
  def pretty_name
    model.name.titleize
  end

  def emoji_and_name(max_width: nil, max_height: nil)
    [emoji_image_tag(max_width: max_width, max_height: max_height), pretty_name].join.html_safe
  end

  def autocomplete_name
    pretty_name
  end

  def listing_name
    pretty_name
  end

  def players_count
    model.players.count
  end

  def emoji_image_url
    "https://cdn.discordapp.com/emojis/#{model.emoji}.png"
  end

  def emoji_image_tag(max_width: nil, max_height: nil)
    return nil if model.emoji.blank?

    h.image_tag_with_max_size emoji_image_url,
                              max_width: max_width,
                              max_height: max_height,
                              class: 'emoji'
  end

  def background_image_data_url
    return nil if model.background_image.blank?

    [
      'data:image/svg+xml;base64',
      Base64.strict_encode64(model.background_image)
    ].join(',')
  end

  def background_image_tag(options = {})
    return nil if model.background_image.blank?

    h.image_tag_with_max_size background_image_data_url, options
  end

  def background_size_display
    return nil if model.background_size.blank?

    "#{model.background_size}px"
  end

  def icon_class
    'gamepad'
  end

  def as_autocomplete_result
    h.tag.div do
      (
        h.tag.div class: :emoji do
          emoji_image_tag
        end
      ) + (
        h.tag.div class: :name do
          pretty_name
        end
      )
    end
  end

  def link(options = {})
    super({
      label: emoji_image_tag,
      title: pretty_name,
      data: { tooltip: {} }
    }.merge(options))
  end

  def nintendo_link(options = {})
    return nil if nintendo_url.blank?

    h.link_to nintendo_url, { target: '_blank', rel: :noopener }.merge(options) do
      (
        h.image_tag 'switch-64.png', height: 32, class: :logo
      ) + ' ' + (
        nintendo_url
      )
    end
  end

  def ultimateframedata_link(options = {})
    return nil if ultimateframedata_url.blank?

    h.link_to ultimateframedata_url, { target: '_blank', rel: :noopener }.merge(options) do
      (
        h.image_tag 'ultimateframedata-32.png', height: 32, class: :logo
      ) + ' ' + (
        ultimateframedata_url
      )
    end
  end

  def smashprotips_link(options = {})
    return nil if smashprotips_url.blank?

    h.link_to smashprotips_url, { target: '_blank', rel: :noopener }.merge(options) do
      (
        h.image_tag 'smashprotips-192.png', height: 32, class: :logo
      ) + ' ' + (
        smashprotips_url
      )
    end
  end

  def first_character_link(options = {})
    character_link Character.first_character, options
  end

  def previous_character_link(options = {})
    character_link previous_character, options
  end

  def next_character_link(options = {})
    character_link next_character, options
  end

  def last_character_link(options = {})
    character_link Character.last_character, options
  end

  private

  def character_link(character, options = {})
    if character
      character.decorate.link(options)
    else
      options[:class] = [
        options[:class],
        :disabled
      ].reject(&:blank?).join(' ')
      h.link_to options[:label], '#', options
    end
  end
end
