# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default("")
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  provider               :string
#  uid                    :string
#  name                   :string
#  measurement_system     :integer          default("imperial_system")
#  import_in_progress     :boolean          default(FALSE)
#  strava_access_token    :string
#  admin                  :boolean          default(FALSE)
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :omniauthable, omniauth_providers: %i[strava]

  has_many :goals, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_and_belongs_to_many :milestones, after_add: :notify_of_milestone_achievement

  has_one_attached :avatar

  validates :email, presence: true, unless: :is_strava_user?
  validates :email, uniqueness: { allow_blank: true }

  enum measurement_system: [ :imperial_system, :metric_system ]
  enum gender: [:prefer_not_to_say, :man, :woman, :non_binary, :other], _default: :prefer_not_to_say

  after_create :send_signup_notice_to_barueat

  ACHIEVEMENTS = {
    member: "has signed up for the #CarFreeChallenge!",
    mission_accomplished: "has achieved a #CarFreeChallenge goal!"
  }

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
    end
  end

  def self.top_three_users_this_month
    leaderboard = User.leaderboard.where('activity_date >= ?', Date.today.beginning_of_month)
    {
      most_distance: leaderboard.order('distance DESC').first,
      most_vert: leaderboard.order('vert DESC').first,
      most_combined: leaderboard.order('combined DESC').first
    }
  end

  def self.leaderboard
    User.joins(:activities)
      .group('users.id')
      .where('NOT opt_out_of_leaderboard')
      .select('
        users.*,
        SUM(activities.vertical_gain) as vert,
        SUM(activities.distance) as distance,
        (SUM(activities.vertical_gain) + SUM(activities.distance)) as combined,
        COUNT(activities) as activity_count'
      )
  end

  def is_strava_user?
    provider == 'strava' and uid.present?
  end

  def total_metric_in_date_range(metric:, start_date: Date.parse("Jan 1 2018"), end_date: Date.parse("Dec 31 2018"))
    counted_activities = activities.where("(activity_date >= ? AND activity_date <= ?) OR (activity_date IS NULL AND created_at >= ? AND created_at <= ?)",
                                       start_date, end_date, start_date, end_date)
    sum = counted_activities.sum(metric)
    if metric_system?
      if metric == 'vertical_gain'
        Goal.feet_to_meters(sum)
      else
        Goal.miles_to_kms(sum)
      end
    else
      sum
    end
  end

  def start_of_earliest_goal
    goals.minimum(:start_date).try(:beginning_of_day)
  end

  # checks the users' activities against the currently available list of milestones
  def matching_milestones
    total_distance = activities.sum(:distance)
    total_vert = activities.sum(:vertical_gain)
    total_carbon = total_distance * 404 / 1000000
    total_combined = total_distance + total_vert

    Milestone.where("
      (metric = 'distance' AND threshold <= ?)
      OR (metric = 'vertical_gain' AND threshold <= ?)
      OR (metric = 'carbon' AND threshold <= ?)
      OR (metric = 'combined' AND threshold <= ?)
      ", total_distance, total_vert, total_carbon, total_combined)
  end
  
  # assigns any milestones that have been achieved to the user
  def update_milestones
    self.milestones = matching_milestones
  end

  def notify_of_milestone_achievement(milestone)
    if email.present?
      unless opt_out_of_barueat_emails
        BarUEatNotificationsMailer.with(user: self, milestone: milestone).notify_of_milestone_achievement.deliver_later
      end

      unless opt_out_of_milestone_notifications
        UserNotificationsMailer.with(user: self, milestone: milestone).notify_of_milestone_achievement.deliver_later
      end
    end
  end

  def send_signup_notice_to_barueat
    if !opt_out_of_barueat_emails
      BarUEatNotificationsMailer.with(user: self).notify_of_new_signup.deliver_later
    end
  end

  def achievements
    achievements = []

    ACHIEVEMENTS.keys.each do |a|
      achievements << a if send(a.to_s + "?")
    end

    achievements
  end

  def member?
    true
  end

  def mission_accomplished?
    goals.where(
      "(SELECT
        CASE goals.metric
          WHEN 'distance' THEN SUM(distance)
          WHEN 'vertical_gain' THEN SUM(vertical_gain)
        END
        AS completed
        FROM activities
        WHERE activities.user_id = goals.user_id AND activity_date >= goals.start_date AND activity_date <= goals.end_date) >= goals.total"
    ).count > 0
  end
end
