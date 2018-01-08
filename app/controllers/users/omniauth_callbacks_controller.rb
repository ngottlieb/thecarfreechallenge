class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def strava
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      session['strava_access_token'] = request.env["omniauth.auth"].credentials.token
      StravaImportJob.perform_later(@user, strava_token)
      set_flash_message(:notice, :success, kind: "Strava") if is_navigational_format?
    else
      session["devise.strava_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end
