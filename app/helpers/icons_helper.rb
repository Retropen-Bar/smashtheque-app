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

  KNOWN_FLAGS = {
    fr: '🇫🇷', # France

    gf: '🇬🇫', # Guyane
    gp: '🇬🇵', # Guadeloupe
    mq: '🇲🇶', # Martinique
    nc: '🇳🇨', # Nouvelle-Caledonie
    pf: '🇵🇫', # Polynesie
    re: '🇷🇪', # Reunion
    yt: '🇾🇹', # Mayotte

    be: '🇧🇪', # Belgique
    ca: '🇨🇦', # Canada
    ch: '🇨🇭', # Suisse
    ma: '🇲🇦', # Maroc
    mc: '🇲🇨'  # Monaco
  }.freeze

  def flag_key(countrycode)
    countrycode.to_s.downcase.to_sym
  end

  def flag_is_known?(countrycode)
    KNOWN_FLAGS.key?(flag_key(countrycode))
  end

  def flag_icon_tag(countrycode, options = {})
    return nil unless flag_is_known?(countrycode)

    classes = ['icon', 'icon--flag']
    classes << options.delete(:class)

    tag.i KNOWN_FLAGS[flag_key(countrycode)], **options.merge(class: classes.join(' '))
  end
end
