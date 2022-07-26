class GoalsController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  # for facebook sharing
  def show
    @goal = Goal.find(params[:id])
    render 'show', layout: nil
  end

  def new
    @goal = Goal.new(
      start_date: Date.today.beginning_of_year,
      end_date: Date.today.end_of_year
    )
  end

  def edit
    @goal = Goal.find(params[:id])
  end

  def update
    @goal = Goal.find(params[:id])
    if @goal.update goal_params
      flash[:notice] = "Goal updated"
      redirect_to dashboard_path
    else
      render 'edit'
    end
  end

  def destroy
    @goal = Goal.find(params[:id])
    @goal.destroy! if @goal.user == current_user
    flash[:notice] = 'Goal abandoned'
    redirect_to dashboard_path
  end

  def create
    @goal = Goal.new(goal_params)
    @goal.user = current_user

    if @goal.save
      flash[:notice] = 'Thanks! Click below to share your goal with your friends!'
      redirect_to dashboard_path
    else
      flash[:error] = 'There was an issue setting your goal.'
      render 'new' 
    end
  end

  private

  def goal_params
    params[:goal][:total].gsub!(',','')
    params.require(:goal).permit(:total, :metric, :start_date, :end_date)
  end
end
