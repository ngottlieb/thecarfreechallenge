class HomeController < ApplicationController
  before_action :authenticate_user!

  def dashboard
    prep_leaderboard_data
  end

  def help
  end

  def site_wide_stats
    # stats are in imperial system by default since that's what's in the db
    @summary = {
      users: User.count,
      vertical_gain_goal: Goal.where(metric: :vertical_gain).sum(:total),
      distance_goal: Goal.where(metric: :distance).sum(:total),
      vertical_gain_sum: Activity.sum(:vertical_gain),
      distance_sum: Activity.sum(:distance)
    }
    if current_user.metric_system?
      @summary[:vertical_gain_goal] = Goal.feet_to_meters(@summary[:vertical_gain_goal])
      @summary[:vertical_gain_sum] = Goal.feet_to_meters(@summary[:vertical_gain_sum])
      @summary[:distance_goal] = Goal.miles_to_kms(@summary[:distance_goal])
      @summary[:distance_sum] = Goal.miles_to_kms(@summary[:distance_sum])
    end
  end

  private

  def prep_leaderboard_data
    @leaderboard = User.top_three_users
  end
end
