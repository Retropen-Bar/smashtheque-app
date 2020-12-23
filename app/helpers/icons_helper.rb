module IconsHelper

  def fas_icon_tag(name, classes = [])
    content_tag :i, '', class: "fas fa-#{name} #{classes.join(' ')}"
  end

end
