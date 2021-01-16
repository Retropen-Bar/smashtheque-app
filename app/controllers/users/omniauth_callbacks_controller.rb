class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def discord
    user = User.from_discord_omniauth(request.env["omniauth.auth"])

    if user && user.persisted?
      if user.is_admin?
        # this will throw if user is not activated
        sign_in_and_redirect user, event: :authentication
        set_flash_message(:notice, :success, kind: "Discord") if is_navigational_format?
      else
        sign_in user
        redirect_to root_path, notice: "Bienvenue, #{user.name}"
      end
    else
      redirect_to root_path
    end
  end

  def failure
    redirect_to root_path
  end
end
