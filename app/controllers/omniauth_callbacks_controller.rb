class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    user = User.from_omniauth(request.env["omniauth.auth"])
    if user and user.persisted?
      flash.notice = "Logged in successfully."
      sign_in_and_redirect user
    elsif ENV.fetch('ALLOW_USER_REGISTRATION', '0') == "1"
      user.save!
      flash.notice = "New user registered!"
      sign_in_and_redirect user
    else
      flash.alert = "You are not registered."
      redirect_to root_path
    end
  end
end
