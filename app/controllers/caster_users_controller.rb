class CasterUsersController < PublicController

  decorates_assigned :caster_user

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  def index
    @caster_users = apply_scopes(User.casters.order("lower(name)")).all
    @meta_title = 'Commentateurs'
  end

end
