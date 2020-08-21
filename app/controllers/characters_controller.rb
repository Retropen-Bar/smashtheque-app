class CharactersController < PublicController

  has_scope :page, default: 1
  has_scope :per

  def index
    @characters = apply_scopes(Character).all
  end

end
