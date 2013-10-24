class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    user = User.from_omniauth(request.env["omniauth.auth"])
    if user and user.persisted?
      flash.notice = "Logged in successfully."
      sign_in_and_redirect user
    else
      flash.alert = "You are not registered."
      redirect_to no_soup_path
    end
  end
end
