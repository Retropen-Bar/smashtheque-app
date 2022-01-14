Rails.application.config.middleware.use OmniAuth::Builder do
  # cf https://discord.com/developers/docs/topics/oauth2#shared-resources-oauth2-scopes
  provider :discord,
           ENV['DISCORD_CLIENT_ID'],
           ENV['DISCORD_CLIENT_SECRET'],
           scope: 'email identify connections'
end
