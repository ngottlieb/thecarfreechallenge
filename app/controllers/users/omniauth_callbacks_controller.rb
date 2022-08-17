class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def strava
    @user = User.from_omniauth(request.env["omniauth.auth"])
    @new_user = @user.new_record?

    if @user.save!
      sign_in @user, event: :authentication
      strava_token = request.env["omniauth.auth"].credentials.token
      refresh_token = request.env["omniauth.auth"].credentials.refresh_token

      @user.update(
        strava_access_token: strava_token,
        strava_refresh_token: refresh_token
      )
      StravaImportJob.perform_later(@user)

      if @new_user
        flash[:info] = "Strava doesn't share your email with us. If you'd like to receive prizes, you'll need to add your email."
        redirect_to edit_user_path(@user)
      else
        set_flash_message(:notice, :success, kind: "Strava") if is_navigational_format?
        redirect_to dashboard_path
      end
    else
      session["devise.strava_data"] = request.env["omniauth.auth"]
      flash[:error] = "There was an issue authenticating with Strava."
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end
