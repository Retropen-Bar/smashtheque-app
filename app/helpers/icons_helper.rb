module IconsHelper
  def fas_icon_tag(name, classes = [])
    tag.i '', class: "fas fa-#{name} #{classes.join(' ')}"
  end

  def fab_icon_tag(name, classes = [])
    tag.i '', class: "fab fa-#{name} #{classes.join(' ')}"
  end

  def svg_icon_tag(name, classes = [])
    file_path = Rails.root.join 'app', 'assets', 'images', 'icons', "#{name}.svg"
    return nil unless File.exist?(file_path)

    File.read(file_path).gsub(
      'viewBox=',
      "class=\"icon icon--#{name} #{classes.join(' ')}\" fill=\"currentColor\" width='1em' height='1em' viewBox="
    ).html_safe
  end
end
