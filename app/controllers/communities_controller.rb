class CommunitiesController < PublicController
  has_scope :page, default: 1
  has_scope :per
  has_scope :on_abc
  has_scope :by_name_like

  layout 'application_v2'

  def index
    @communities = apply_scopes(Community.order('LOWER(name)')).all
    @meta_title = 'Communautés'
  end

  def show
    @community = Community.find(params[:id]).decorate
    @meta_title = @community.name
    @meta_properties['og:type'] = 'profile'
    @meta_properties['og:image'] = @community.decorate.any_image_url
  end
end
