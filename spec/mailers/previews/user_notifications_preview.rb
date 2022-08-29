# Preview all emails at http://localhost:3000/rails/mailers/user_notifications
class UserNotificationsPreview < ActionMailer::Preview
  def notify_of_milestone_achievement
    UserNotificationsMailer.with(user: User.first, milestone: Milestone.first).notify_of_milestone_achievement
  end
end
