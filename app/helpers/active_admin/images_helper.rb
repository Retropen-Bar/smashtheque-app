module ActiveAdmin::ImagesHelper

  # add support for :
  # - link_options
  # - max_height
  # - max_width
  # - with_link
  def image_tag_with_max_size(source, options = {})
    options = options.symbolize_keys

    max_width = options.delete(:max_width)
    max_width = "#{max_width}px" if max_width && max_width.is_a?(Integer)
    max_height = options.delete(:max_height)
    max_height = "#{max_height}px" if max_height && max_height.is_a?(Integer)
    with_link = options.delete(:with_link)
    link_options = options.delete(:link_options)

    # max size

    style = []
    if max_width
      max_width = "#{max_width}px" if max_width.is_a?(Integer)
      style << "max-width: #{max_width};"
    end
    if max_height
      max_height = "#{max_height}px" if max_height.is_a?(Integer)
      style << "max-height: #{max_height};"
    end
    style << options.delete(:style)

    # tag itself

    tag = image_tag source, options.merge(style: style.join)

    # link

    if with_link
      link_to tag, source, link_options
    else
      tag
    end
  end

end
