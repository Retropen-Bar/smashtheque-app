module ApplicationHelper

  def toastr_method_for_flash(flash_type)
    case flash_type
    when 'success', 'error'
      flash_type
    when 'alert'
      :warning
    else
      :info
    end
  end

  def pluralize_without_count(count, noun)
    count == 1 ? noun : noun.pluralize
  end

  def admin_edit_link(resource)
    if admin_user_signed_in?
      link_to fas_icon_tag('cog'), [:admin, resource], target: '_blank', class: 'admin-edit-link'
    end
  end

  def current_class?(path)
    return ' active' if request.path == path
    ''
  end

  def current_section?(section_name)
    case section_name
    when :players
      return true if controller_name.match(/(players|teams|duos|communities|characters)/)
    when :tournaments
      return true if controller_name.match(/(recurring_tournaments|tournament_events)/)
    else
      return false
    end
  end
  
  def current_section_name
    return :players if current_section?(:players)
    return :tournaments if current_section?(:tournaments)
  end

  def url_with(changes)
    url_for(current_page_params.merge(changes))
  end

  def hex_color_to_rgba(hex, opacity)
    rgb = hex.match(/^#(..)(..)(..)$/).captures.map(&:hex)
    "rgba(#{rgb.join(", ")}, #{opacity})"
  end

  def darken_color(hex_color, amount=0.4)
    hex_color = hex_color.gsub('#','')
    rgb = hex_color.scan(/../).map {|color| color.hex}
    rgb[0] = (rgb[0].to_i * amount).round
    rgb[1] = (rgb[1].to_i * amount).round
    rgb[2] = (rgb[2].to_i * amount).round
    "#%02x%02x%02x" % rgb
  end
    
  # Amount should be a decimal between 0 and 1. Higher means lighter
  def lighten_color(hex_color, amount=0.6)
    hex_color = hex_color.gsub('#','')
    rgb = hex_color.scan(/../).map {|color| color.hex}
    rgb[0] = [(rgb[0].to_i + 255 * amount).round, 255].min
    rgb[1] = [(rgb[1].to_i + 255 * amount).round, 255].min
    rgb[2] = [(rgb[2].to_i + 255 * amount).round, 255].min
    "#%02x%02x%02x" % rgb
  end

  def contrasting_text_color(hex_color)
    color = hex_color.gsub('#','')
    convert_to_brightness_value(color) > 382.5 ? darken_color(color) : lighten_color(color)
  end
  
  def convert_to_brightness_value(hex_color)
    (hex_color.scan(/../).map {|color| color.hex}).sum
  end
end
