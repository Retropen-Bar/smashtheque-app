module IconsHelper
  def fas_icon_tag(name, classes = [])
    tag.i '', class: "fas fa-#{name} #{classes.join(' ')}"
  end

  def fab_icon_tag(name, classes = [])
    tag.i '', class: "fab fa-#{name} #{classes.join(' ')}"
  end

  def svg_icon_tag(name, options = {})
    file_path = Rails.root.join 'app', 'assets', 'images', 'icons', "#{name}.svg"
    return nil unless File.exist?(file_path)

    classes = []
    classes << "icon icon--#{name}"
    classes << options.delete(:class)

    File.read(file_path).gsub(
      'viewBox=',
      "class=\"#{classes.join(' ')}\" fill=\"currentColor\" width='1em' height='1em' viewBox="
    ).html_safe
  end

  def flag_icon_tag(countrycode, options = {})
    return nil if countrycode.blank?

    cc = countrycode.to_s.downcase
    return nil unless cc.match?(/\A[a-z]{2}\z/)

    classes = ['flag-icon', "flag-icon-#{cc}"]
    classes << options.delete(:class)

    tag.span '', **options.merge(class: classes.join(' '))
  end
end
