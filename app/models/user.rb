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

  has_many :goals
  has_many :activities
  has_and_belongs_to_many :milestones, after_add: :notify_of_milestone_achievement

  has_one_attached :avatar

  validates :email, presence: true, unless: :is_strava_user?

  enum measurement_system: [ :imperial_system, :metric_system ]
  enum gender: [:prefer_not_to_say, :man, :woman, :non_binary, :other], _default: :prefer_not_to_say

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create! do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      #user.image = auth.info.image # assuming the user model has an image
    end
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

    Milestone.where("(metric = 'distance' AND threshold <= ?) OR (metric = 'vertical_gain' AND threshold <= ?)", total_distance, total_vert)
  end
  
  # assigns any milestones that have been achieved to the user
  def update_milestones
    self.milestones = matching_milestones
  end

  def notify_of_milestone_achievement(milestone)
    BarUEatNotificationsMailer.with(user: self, milestone: milestone).notify_of_milestone_achievement.deliver_later
  end
end
