class Api::V1::DiscordUsersController < Api::V1::BaseController
  def show
    discord_user = DiscordUser.find_by(discord_id: params[:discord_id])
    render json: discord_user
  end

  def refetch
    discord_user = DiscordUser.find_by(discord_id: params[:discord_id])
    discord_user.fetch_discord_data
    if discord_user.save
      discord_user.update_discord_roles
      discord_user.user&.refetch_smashgg_users
      render json: discord_user
    else
      render_errors discord_user.errors, :unprocessable_entity
    end
  end
end
