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

end
