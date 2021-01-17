class TwitchChannelsController < PublicController

  decorates_assigned :twitch_channel

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  def index
    @twitch_channels = apply_scopes(TwitchChannel.order("lower(display_name)")).all
  end

end
