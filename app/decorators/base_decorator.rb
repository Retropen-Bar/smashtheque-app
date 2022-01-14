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

  def twitch_link
    return nil if model.twitch_username.blank?

    h.link_to "https://www.twitch.tv/#{model.twitch_username}", target: '_blank', rel: :noopener do
      (
        h.fab_icon_tag :twitch
      ) + ' ' + (
        h.tag.span model.twitch_username
      )
    end
  end

  def youtube_link
    return nil if model.youtube_username.blank?

    h.link_to '#' do
      (
        h.fab_icon_tag :youtube
      ) + ' ' + (
        h.tag.span model.youtube_username
      )
    end
  end

  def path
    model
  end

  def link(options = {})
    txt = options.delete(:label) || name
    url = options.delete(:url) || path
    h.link_to txt, url, options
  end

  def address_with_coordinates
    return nil if address.blank?

    "#{address} (#{latitude}, #{longitude})"
  end

  def country_name
    return nil if countrycode.blank?

    ISO3166::Country.new(countrycode)&.translation('fr')
  end

  def country_flag(options = {})
    return nil if countrycode.blank?

    h.flag_icon_tag(countrycode, options)
  end

  def country_name_with_flag(options = {})
    return nil if countrycode.blank?

    [
      country_flag(options),
      country_name
    ].join('&nbsp;').html_safe
  end
end
