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
      return true if controller_name.match(/(players|teams|duos|communities)/)
    else
      return false
    end
  end
  
  def current_section_name
    return :players if current_section?(:players)
  end

  def url_with(changes)
    url_for(current_page_params.merge(changes))
  end
end
