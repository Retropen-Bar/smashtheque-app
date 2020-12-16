class ActiveAdmin::RewardDecorator < RewardDecorator
  include ActiveAdmin::BaseDecorator

  decorates :reward

  def admin_link(options = {})
    super(options.merge(label: badge))
  end

end
