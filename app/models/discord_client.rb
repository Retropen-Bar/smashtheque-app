class DiscordClient
  def initialize(token: nil)
    @token = token || ENV['DISCORD_BOT_TOKEN']
  end

  def get_current_user_connections(user_token)
    api_get '/users/@me/connections', auth: "Bearer #{user_token}"
  end

  def get_user(user_id)
    api_get "/users/#{user_id}"
  end

  def get_guild(guild_id)
    api_get "/guilds/#{guild_id}"
  end

  def get_guild_from_invitation(invitation_url)
    invitation_code = invitation_url.strip.gsub(
      'https://discord.gg/invite/', ''
    ).gsub(
      'https://discord.gg/', ''
    ).gsub(
      'https://discord.com/invite/', ''
    ).gsub(
      'https://discord.com/', ''
    ).gsub(
      'https://discordapp.com/invite/', ''
    ).gsub(
      'https://discordapp.com/', ''
    )

    api_get "/invites/#{invitation_code}"
  end

  def add_role_to_user(guild_id:, user_id:, role_id:)
    Rails.logger.debug "[DiscordClient] adding role #{role_id} to member #{user_id}"
    guild = bot.server(guild_id)
    member = guild.member(user_id)
    if member.nil?
      Rails.logger.debug "Account #{user_id} is not a member of this guild"
      return false
    end
    if member.roles.map(&:id).include?(role_id.to_i)
      Rails.logger.debug "Member #{user_id} already has role #{role_id}"
      return false
    end
    member.set_roles(member.roles.map(&:id) + [role_id.to_i])
  end

  def remove_role_from_user(guild_id:, user_id:, role_id:)
    Rails.logger.debug "[DiscordClient] removing role #{role_id} from member #{user_id}"
    guild = bot.server(guild_id)
    member = guild.member(user_id)
    if member.nil?
      Rails.logger.debug "Account #{user_id} is not a member of this guild"
      return false
    end
    unless member.roles.map(&:id).include?(role_id.to_i)
      Rails.logger.debug "Member #{user_id} does not have role #{role_id}"
      return false
    end
    member.set_roles(member.roles.map(&:id) - [role_id.to_i])
  end

  def toggle_user_role(toggle, guild_id:, user_id:, role_id:)
    if toggle
      add_role_to_user(guild_id: guild_id, user_id: user_id, role_id: role_id)
    else
      remove_role_from_user(guild_id: guild_id, user_id: user_id, role_id: role_id)
    end
  end

  private

  def api_get(path, auth: "Bot #{@token}")
    Rails.logger.debug '=== API REQUEST ==='
    url = URI("#{Discordrb::API::APIBASE}#{path}")
    Rails.logger.debug "GET #{url}"

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request['Authorization'] = auth

    response = https.request(request)

    JSON.parse(response.read_body)
  rescue JSON::ParserError
    {}
  end

  def bot
    @bot ||= begin
      b = Discordrb::Bot.new token: @token
      b.run true
      b
    end
  end
end
