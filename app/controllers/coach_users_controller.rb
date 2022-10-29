class CoachUsersController < PublicController
  layout 'application_v2'

  decorates_assigned :coach_user

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  def index
    @coach_users = apply_scopes(User.coaches.order("lower(name)")).all
    @meta_title = 'Coachs'
  end

end
