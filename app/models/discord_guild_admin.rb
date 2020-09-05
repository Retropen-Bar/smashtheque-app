class DiscordGuildAdmin < ApplicationRecord

  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :discord_guild
  belongs_to :discord_user

end
