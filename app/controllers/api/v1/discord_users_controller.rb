class Api::V1::DiscordUsersController < Api::V1::BaseController

  def show
    discord_user = DiscordUser.find_by(discord_id: params[:discord_id])
    render json: discord_user
  end

end
