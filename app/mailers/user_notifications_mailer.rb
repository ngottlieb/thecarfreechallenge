class UserNotificationsMailer < ApplicationMailer
  default from: 'barueat@thecarfreechallenge.com'
  helper MilestonesHelper
  include MilestonesHelper

  def notify_of_milestone_achievement
    @user = params[:user]
    @milestone = params[:milestone]

    if @milestone.tagline.present?
      subject = "Congrats! You earned the #{@milestone.tagline} badge!"
    else
      subject = "Congrats! You've #{milestone_achievement_verb(@milestone)} #{friendly_display_of_threshold(@milestone, @user)}"
    end
    
    mail(
      subject: subject,
      to: @user.email
    )
  end
end
