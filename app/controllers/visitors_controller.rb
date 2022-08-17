class VisitorsController < ApplicationController
  layout 'visitors'
  
  def index
    @summary = {
      users: User.count,
      vertical_gain_goal: Goal.where(metric: :vertical_gain).sum(:total),
      distance_goal: Goal.where(metric: :distance).sum(:total),
      vertical_gain_sum: Activity.sum(:vertical_gain),
      distance_sum: Activity.sum(:distance)
    }

    @leaderboard = User.top_three_users
  end
end
