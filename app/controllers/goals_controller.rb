class GoalsController < ApplicationController
  before_action :authenticate_user!

  def index
    @goal = Goal.new
  end

  def create
    @goal = Goal.new(goal_params)
    @goal.user = current_user
    if @goal.save
      flash[:notice] = 'Thanks! Click below to share your goal with your friends!'
      redirect_to goals_url
    else
      flash[:error] = 'There was an issue setting your goal.'
      redirect_to goals_url
    end
  end

  private

  def goal_params
    params.require(:goal).permit(:total, :metric)
  end
end
