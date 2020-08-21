class CharactersController < PublicController

  def index
    @characters = Character.all
  end

end
