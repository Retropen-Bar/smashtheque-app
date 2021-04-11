class YouTubeChannelsController < PublicController

  decorates_assigned :you_tube_channel

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  def index
    @you_tube_channels = apply_scopes(YouTubeChannel.order("lower(name)")).all
    @meta_title = 'Chaînes YouTube'
  end

end
