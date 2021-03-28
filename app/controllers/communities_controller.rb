class CommunitiesController < PublicController

  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc
  has_scope :by_name_like

  def index
    @communities = apply_scopes(Community.order("lower(name)")).all
  end

end
