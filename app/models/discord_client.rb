class DiscordClient

  MESSAGE_LINE_SEPARATOR = "\n".freeze

  def initialize(token: nil)
    @token = token || ENV['DISCORD_BOT_TOKEN']
  end

  def get_user(user_id)
    api_get "/users/#{user_id}"
  end

  def get_guild(guild_id)
    api_get "/guilds/#{guild_id}"
  end

  def get_guild_roles(guild_id)
    # cache is problematic for now
    # @guild_roles ||= {}
    # @guild_roles[guild_id] ||= api_get "/guilds/#{guild_id}/roles"
    api_get "/guilds/#{guild_id}/roles"
  end

  def find_guild_role_id(guild_id, role_name)
    get_guild_roles(guild_id).each do |role|
      return role['id'] if role['name'] == role_name
    end
    nil
  end

  def bot_user_id
    bot.profile.id.to_s
  end

  def find_guild_bot_role_id(guild_id)
    get_guild_roles(guild_id).each do |role|
      return role['id'] if (role['tags'] || {})['bot_id'] == bot_user_id
    end
    nil
  end

  def get_guild_emojis(guild_id)
    # cache is problematic for now
    # @guild_emojis ||= {}
    # @guild_emojis[guild_id] ||= api_get "/guilds/#{guild_id}/emojis"
    api_get "/guilds/#{guild_id}/emojis"
  end

  def find_guild_emoji_id(guild_id, emoji_name)
    get_guild_emojis(guild_id).each do |emoji|
      return emoji['id'] if emoji['available'] && emoji['name'] == emoji_name
    end
    nil
  end

  def get_guild_channels(guild_id)
    # cache is problematic for now
    # @guild_channels ||= {}
    # @guild_channels[guild_id] ||= api_get "/guilds/#{guild_id}/channels"
    api_get "/guilds/#{guild_id}/channels"
  end

  def create_guild_category(guild_id, params)
    api_post "/guilds/#{guild_id}/channels", params.merge(
      type: 4 #GUILD_CATEGORY
    )
  end

  def find_or_create_guild_category(guild_id, find_params, create_params = {})
    existing_channels = get_guild_channels(guild_id)
    found_channel = existing_channels.find do |channel|
      compare_existing channel, find_params
    end
    return found_channel if found_channel
    create_guild_category(guild_id, find_params.merge(create_params))
  end

  def create_guild_text_channel(guild_id, params)
    api_post "/guilds/#{guild_id}/channels", params.merge(
      type: 0 #GUILD_TEXT
    )
  end

  def find_or_create_guild_text_channel(guild_id, find_params, create_params = {})
    existing_channels = get_guild_channels(guild_id)
    found_channel = existing_channels.find do |channel|
      compare_existing channel, find_params
    end
    return found_channel if found_channel

    # create
    read_only = create_params.delete(:readonly)
    params = find_params.merge(create_params)
    if read_only
      everyone_id = find_guild_role_id guild_id, '@everyone'
      bot_role_id = find_guild_bot_role_id guild_id
      raise 'Role @everyone not found on guild' unless everyone_id
      params[:permission_overwrites] = [
        {
          type: :role,
          id: everyone_id,
          allow: 0,
          deny: 456768 # deny everything to @everyone
        }, {
          type: :role,
          id: bot_role_id,
          deny: 0,
          allow: 523328 # allow all text operations to bot
        }
      ]
    end

    create_guild_text_channel(guild_id, params)
  end

  def channel(channel_id)
    # cache is problematic for now
    # @channels ||= {}
    # @channels[channel_id] ||= api_get "/channels/#{channel_id}"
    api_get "/channels/#{channel_id}"
  end

  def delete_channel(channel_id)
    api_delete "/channels/#{channel_id}"
  end

  def channel_messages(channel_id, limit = 100)
    raise 'Channel ID is empty' if channel_id.blank?
    messages = api_get "/channels/#{channel_id}/messages?limit=#{limit}"
    return [] if messages.is_a?(Hash)
    messages.sort_by { |message| message['timestamp'] }
  end

  def create_channel_message(channel_id, content)
    raise 'Channel ID is empty' if channel_id.blank?
    return false if content.blank?
    split_messages(content).each do |message|
      bot.send_message channel_id, message
    end
  end

  def edit_channel_message(channel_id, message_id, content)
    return false if content.blank?
    api_patch "/channels/#{channel_id}/messages/#{message_id}", content: content
  end

  def delete_channel_message(channel_id, message_id)
    api_delete "/channels/#{channel_id}/messages/#{message_id}"
  end

  def clear_channel(channel_id)
    channel_messages(channel_id).each do |message|
      delete_channel_message channel_id, message['id']
    end
  end

  def replace_channel_content(channel_id, content)
    content = '-' if content.blank?

    existing_messages = channel_messages channel_id
    new_messages = split_messages content

    message_idx = 0
    new_messages.each do |new_message|
      if message_idx < existing_messages.count
        # an existing message is available for edition
        edit_channel_message channel_id, existing_messages[message_idx]['id'], new_message
      else
        # all existing messages have been used, we need to create more
        create_channel_message channel_id, new_message
      end
      message_idx += 1
    end

    # some old messages might still be here and need to be deleted
    while message_idx < existing_messages.count
      delete_channel_message channel_id, existing_messages[message_idx]['id']
      message_idx += 1
    end
  end

  private

  def api_get(path)
    puts "=== API REQUEST ==="
    url = URI("#{Discordrb::API::APIBASE}#{path}")
    puts "GET #{url}"

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "Bot #{@token}"

    response = https.request(request)

    JSON.parse(response.read_body)
  end

  def api_post(path, params)
    puts "=== API REQUEST ==="
    url = URI("#{Discordrb::API::APIBASE}#{path}")
    puts "POST #{url} #{params.to_json}"

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Authorization"] = "Bot #{@token}"
    request["Content-Type"] = 'application/json'
    request.body = params.to_json

    response = https.request(request)

    JSON.parse(response.read_body)
  end

  def api_patch(path, params)
    puts "=== API REQUEST ==="
    url = URI("#{Discordrb::API::APIBASE}#{path}")
    puts "PATCH #{url} #{params.to_json}"

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Patch.new(url)
    request["Authorization"] = "Bot #{@token}"
    request["Content-Type"] = 'application/json'
    request.body = params.to_json

    response = https.request(request)

    puts "=== API RESPONSE ==="
    puts response.inspect

    if response.is_a?(Net::HTTPTooManyRequests)
      puts 'too many requests, wait for a bit and retry'
      sleep 5
      api_patch(path, params)
    else
      JSON.parse(response.read_body)
    end
  end

  def api_delete(path)
    puts "=== API REQUEST ==="
    url = URI("#{Discordrb::API::APIBASE}#{path}")
    puts "DELETE #{url}"

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Delete.new(url)
    request["Authorization"] = "Bot #{@token}"

    response = https.request(request)

    response.read_body
  end

  # helpers

  def compare_existing(existing, tests)
    symbolized_existing = existing.symbolize_keys
    tests.each do |test_k, test_v|
      return false if symbolized_existing[test_k.to_sym] != test_v
    end
    true
  end

  def split_messages(lines)
    messages = []
    current_message = ""
    current_message_size = 0

    lines.split(MESSAGE_LINE_SEPARATOR).each do |line|
      if current_message_size + line.size < Discordrb::CHARACTER_LIMIT - 10
        # ok to be added
        current_message += MESSAGE_LINE_SEPARATOR unless current_message_size.zero?
        current_message += line
        current_message_size = current_message.size
      else
        # too long
        messages << current_message
        current_message = line
        current_message_size = current_message.size
      end
    end
    messages << current_message

    messages
  end

  def bot
    @bot ||= (
      b = Discordrb::Bot.new token: @token
      b.run true
      b
    )
  end

end
