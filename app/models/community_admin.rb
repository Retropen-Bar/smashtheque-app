# == Schema Information
#
# Table name: community_admins
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_community_admins_on_community_id              (community_id)
#  index_community_admins_on_community_id_and_user_id  (community_id,user_id) UNIQUE
#  index_community_admins_on_user_id                   (user_id)
#
class CommunityAdmin < ApplicationRecord
  # ---------------------------------------------------------------------------
  # RELATIONS
  # ---------------------------------------------------------------------------

  belongs_to :community
  belongs_to :user
end
