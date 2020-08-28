class Api::V1::CharactersController < Api::V1::BaseController

  has_scope :by_emoji

  def index
    characters = apply_scopes(Character).all
    render json: characters
  end

end
