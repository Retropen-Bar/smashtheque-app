class RedirectionsController < PublicController
  def bot
    redirect_to ENV['DISCORD_BOT_URL'], status: 302
  end

  def charter
    redirect_to ENV['CHARTER_URL'], status: 302
  end
end
