class CharactersController < PublicController

  has_scope :by_emoji

  def index
    @characters = apply_scopes(Character).all
  end

end
