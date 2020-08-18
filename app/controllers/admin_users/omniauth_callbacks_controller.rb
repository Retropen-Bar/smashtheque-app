class AdminUsers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def discord
    admin_user = AdminUser.from_omniauth(request.env["omniauth.auth"])

    if admin_user && admin_user.persisted?
      # this will throw if admin_user is not activated
      sign_in_and_redirect admin_user, event: :authentication
      set_flash_message(:notice, :success, kind: "Discord") if is_navigational_format?
    else
      redirect_to root_path
    end
  end

  def failure
    redirect_to root_path
  end
end
