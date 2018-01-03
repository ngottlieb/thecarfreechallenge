# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
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
#  measurement_system     :string           default("imperial")
#  name                   :string
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: %i[strava]

  has_many :goals
  has_many :activities

  enum measurement_system: [ :imperial, :metric ]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      #user.image = auth.info.image # assuming the user model has an image
    end
  end

  def is_strava_user?
    provider == 'strava' and uid.present?
  end

  def total_metric_in_date_range(metric, start_date=Date.parse("Jan 1 2018"), end_date=Date.parse("Dec 31 2018"))
    counted_activities = activities.where("(activity_date >= ? AND activity_date <= ?) OR (activity_date IS NULL AND created_at >= ? AND created_at <= ?)",
                                       start_date, end_date, start_date, end_date)
    counted_activities.sum(metric)
  end
end
