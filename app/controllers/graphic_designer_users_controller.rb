class GraphicDesignerUsersController < PublicController
  layout 'application_v2'

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc
  has_scope :by_community_id

  def index
    @graphic_designer_users = apply_scopes(User.graphic_designers.order('lower(name)')).all
    @meta_title = 'Graphistes'
  end
end
