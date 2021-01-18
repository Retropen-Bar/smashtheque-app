class GraphicDesignerUsersController < PublicController

  decorates_assigned :graphic_designer_user

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc

  def index
    @graphic_designer_users = apply_scopes(User.graphic_designers.order("lower(name)")).all
  end

end
