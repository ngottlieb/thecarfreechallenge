class ActivitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    @activities = current_user.activities
  end

  def create
    @activity = Activity.new(activity_params)
    @activity.user = current_user
    if @activity.save
      flash[:notice] = 'Thanks for logging your progress!'
      redirect_to activities_url
    else
      render 'new'
    end
  end

  def new
    @activity = Activity.new
  end

  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy! if @activity.user == current_user
    flash[:notice] = 'Activity deleted'
    redirect_to activities_path
  end

  def trigger_import
    if current_user.is_strava_user?
      StravaImportJob.perform_later(current_user, strava_token)
      respond_to do |format|
        format.json { render json: { msg: "Enqueued Strava import job" }, status: :created }
      end
    else
      respond_to do |format|
        format.json { render json: { errors: ["#{current_user} is not a Strava user"] }, status: :error }
      end
    end
  end

  private

  def activity_params
    params[:activity][:distance].gsub!(',','')
    params[:activity][:vertical_gain].gsub!(',','')
    params.require(:activity).permit(:distance, :vertical_gain, :activity_date, :sport, :name)
  end
end
