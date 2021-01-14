class Api::V1::DiscordUsersController < Api::V1::BaseController

  def show
    discord_user = DiscordUser.find_by(discord_id: params[:discord_id])
    render json: discord_user
  end

  def refetch
    discord_user = DiscordUser.find_by(discord_id: params[:discord_id])
    discord_user.fetch_discord_data
    if !discord_user.save
      render_errors discord_user.errors, :unprocessable_entity
    end
    render json: discord_user
  end

end
