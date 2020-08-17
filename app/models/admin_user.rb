class AdminUser < ApplicationRecord

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  devise :omniauthable, omniauth_providers: %i[discord]

  def self.from_omniauth(auth)
    puts "User#from_omniauth(#{auth.inspect})"

    user = find_by(email: auth.info.email)
    return false if user.nil?

    case auth.provider.to_sym
    when :discord
      user.avatar_url = auth.info.image
      user.name = auth.info.name
      user.discord_username = auth.extra.raw_info.username
      user.discord_discriminator = auth.extra.raw_info.discriminator
      user.save!
    end

    user
  end

end
