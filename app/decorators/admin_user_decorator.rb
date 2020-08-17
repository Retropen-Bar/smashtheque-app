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

  def avatar_tag(max_width: max_width, max_height: max_height)
    h.image_tag_with_max_size model.avatar_url,
                              max_width: max_width,
                              max_height: max_height
  end

end
