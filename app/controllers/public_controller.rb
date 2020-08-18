class PublicController < ApplicationController

  before_action :authenticate_admin_user!

  def home

  end

end
