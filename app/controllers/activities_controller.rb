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

  private

  def activity_params
    params[:activity][:distance].gsub!(',','')
    params[:activity][:vertical_gain].gsub!(',','')
    params.require(:activity).permit(:distance, :vertical_gain, :activity_date, :sport)
  end
end
