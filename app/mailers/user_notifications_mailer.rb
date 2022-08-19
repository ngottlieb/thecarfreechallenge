class UserNotificationsMailer < ApplicationMailer
  default from: 'barueat@thecarfreechallenge.com'
  helper MilestonesHelper
  include MilestonesHelper

  def notify_of_milestone_achievement
    @user = params[:user]
    @milestone = params[:milestone]
    verb = @milestone.metric == 'distance' ? "traveled" : "gained"
    mail(
      subject: "Congrats! You've #{verb} #{friendly_display_of_threshold(@milestone, @user)}",
      to: @user.email
    )
  end
end