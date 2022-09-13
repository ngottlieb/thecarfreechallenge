class ActivitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.import_in_progress?
      flash[:notice] = "Importing can take a few minutes. Check back in a bit!"
    end
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

  def edit
    @activity = Activity.find(params[:id])
  end

  def update
    @activity = Activity.find(params[:id])
    if @activity.update activity_params
      flash[:notice] = "Activity updated"
      redirect_to activities_url
    else
      render 'edit'
    end
  end

  def trigger_import
    if current_user.is_strava_user?
      StravaImportJob.perform_later(current_user)
    end
    redirect_to activities_url
  end

  private

  def activity_params
    # if both metrics are blank, the activity is invalid, but if only one is blank, the other needs to be set to 0
    unless params[:activity][:distance].blank? && params[:activity][:vertical_gain].blank?
      [:distance, :vertical_gain].each do |metric|
        params[:activity][metric].gsub!(',','')
        params[:activity][metric] = 0 if params[:activity][metric].blank?
      end
    end

    params.require(:activity).permit(:distance, :vertical_gain, :activity_date, :sport, :name)
  end
end
