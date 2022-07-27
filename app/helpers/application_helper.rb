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

  def admin_edit_link(resource, options = {})
    return unless admin_user_signed_in?

    classes = [
      'admin-edit-link',
      options.delete(:class)
    ].join(' ')
    text = options.delete(:label) || fas_icon_tag('cog')
    link_to text,
            [:admin, resource],
            { target: '_blank', rel: :noopener, class: classes }.merge(options)
  end

  def current_class?(path_prefix, condition = true)
    return ' active' if request.path.starts_with?(path_prefix) && condition

    ''
  end

  def current_section?(section_name)
    case section_name
    when :players
      controller_name =~ /(players|teams|duos|communities|characters)/ && action_name !~ /(ranking)/
    when :tournaments
      controller_name =~ /(tournament)/ || action_name =~ /(planning)/
    when :rosalina
      action_name =~ /(ranking)/
    else
      false
    end
  end

  def current_section_name
    return :players if current_section?(:players)
    return :tournaments if current_section?(:tournaments)
    return :rosalina if current_section?(:rosalina)
  end

  def url_with(changes)
    page_params = defined?(current_page_params) ? current_page_params : {}
    url_for(page_params.merge(changes))
  end

  def hex_color_to_rgba(hex, opacity)
    rgb = hex.match(/^#(..)(..)(..)$/).captures.map(&:hex)
    "rgba(#{rgb.join(', ')}, #{opacity})"
  end

  def darken_color(hex_color, amount = 0.4)
    hex_color = hex_color.delete('#')
    rgb = hex_color.scan(/../).map { |color| color.hex }
    rgb[0] = (rgb[0].to_i * amount).round
    rgb[1] = (rgb[1].to_i * amount).round
    rgb[2] = (rgb[2].to_i * amount).round
    '#%02x%02x%02x' % rgb
  end

  # Amount should be a decimal between 0 and 1. Higher means lighter
  def lighten_color(hex_color, amount = 0.6)
    hex_color = hex_color.delete('#')
    rgb = hex_color.scan(/../).map { |color| color.hex }
    rgb[0] = [(rgb[0].to_i + (255 * amount)).round, 255].min
    rgb[1] = [(rgb[1].to_i + (255 * amount)).round, 255].min
    rgb[2] = [(rgb[2].to_i + (255 * amount)).round, 255].min
    '#%02x%02x%02x' % rgb
  end

  def contrasting_text_color(hex_color)
    color = hex_color.delete('#')
    convert_to_brightness_value(color) > 382.5 ? darken_color(color) : lighten_color(color)
  end

  def convert_to_brightness_value(hex_color)
    (hex_color.scan(/../).map { |color| color.hex }).sum
  end

  def simple_link_to_add_fields(name, form, association, options = {})
    new_object = form.object.send(association).klass.new
    id = new_object.object_id
    fields = form.simple_fields_for(association, new_object, child_index: id) do |builder|
      render("#{association.to_s.singularize}_fields", f: builder)
    end

    options[:class] = "add-nested-fields #{options[:class]}"
    link_to name, '#', { data: { id: id, fields: fields.delete("\n") } }.merge(options)
  end

  def link_to_rm_fields(name, options = {})
    options[:class] = "rm-nested-fields #{options[:class]}"
    link_to name, '#', options
  end
end
