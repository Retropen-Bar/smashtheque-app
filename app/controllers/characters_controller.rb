class CharactersController < ApplicationController

  has_scope :page, default: 1
  has_scope :per

  def index
    @characters = apply_scopes(Character).all
  end

  def show
    @character = Character.find(params[:id]).decorate
    @players = apply_scopes(@character.model.players)
  end

end
