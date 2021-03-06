class BaseDecorator < Draper::Decorator
  delegate_all

  include Rails.application.routes.url_helpers

  def created_at_date
    h.l model.created_at.to_date, format: :default
  end

  def updated_at_date
    h.l model.updated_at.to_date, format: :default
  end

  def twitter_url
    return nil if model.twitter_username.blank?

    "https://twitter.com/#{model.twitter_username}"
  end

  def twitter_link(options = {})
    return nil if model.twitter_username.blank?

    txt = options.delete(:label) || [
      h.fab_icon_tag(:twitter),
      model.twitter_username
    ].join('&nbsp;').html_safe

    h.link_to txt, twitter_url, { target: '_blank', rel: :noopener }.merge(options)
  end

  def twitter_name
    return nil if twitter_username.blank?

    "@#{twitter_username}"
  end

  def path
    model
  end

  def link(options = {})
    txt = options.delete(:label) || name
    url = options.delete(:url) || path
    h.link_to txt, url, options
  end
end
