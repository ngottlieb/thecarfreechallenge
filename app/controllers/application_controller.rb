class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :measurement_system])
  end

  def has_strava_token?
    session['strava_access_token'].present?
  end

  def strava_token
    session['strava_access_token']
  end
end
