class DiscordUsersController < PublicController

  before_action :set_discord_user, only: %w(refetch)

  def refetch
    @discord_user.fetch_discord_data
    if !@discord_user.save
      flash[:error] = 'Impossible de mettre à jour les données'
      redirect_to request.referrer and return
    end
    redirect_to request.referrer, notice: 'Données mises à jour'
  end

  private

  def set_discord_user
    @discord_user = DiscordUser.find(params[:id])
  end

end
