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
      flash[:error] = 'There was an error logging your progress.'
      redirect_to activities_url
    end
  end

  def new
    @activity = Activity.new
  end

  private

  def activity_params
    params.require(:activity).permit(:distance, :vertical_gain, :activity_date, :sport)
  end
end