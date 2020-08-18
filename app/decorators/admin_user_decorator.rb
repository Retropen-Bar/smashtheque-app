class AdminUserDecorator < BaseDecorator

  def discord_full_username
    [
      model.discord_username,
      discord_discriminator
    ].join('#')
  end

  def email_link
    h.mail_to model.email
  end

  def avatar_tag(max_width: nil, max_height: nil)
    return nil if model.avatar_url.blank?
    h.image_tag_with_max_size model.avatar_url,
                              max_width: max_width,
                              max_height: max_height
  end

end
