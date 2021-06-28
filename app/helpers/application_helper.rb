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

  def current_section?(section_name)
    case section_name
    when :players
      return true if controller_name.match(/(players|teams|duos)/)
    else
      return false
    end
  end
end
