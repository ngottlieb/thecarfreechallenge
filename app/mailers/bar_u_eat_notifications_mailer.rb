class BarUEatNotificationsMailer < ApplicationMailer
  default to: ENV['BAR_U_EAT_ADMIN_EMAIL'] || 'nick@thecarfreechallenge.com'

  def notify_of_milestone_achievement
    @user = params[:user]
    @milestone = params[:milestone]
    mail(subject: "User achieved milestone")
  end

  def notify_of_new_signup
    @user = params[:user]
    mail(subject: "New user signed up")
  end
end
