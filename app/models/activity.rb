# == Schema Information
#
# Table name: activities
#
#  id            :bigint           not null, primary key
#  distance      :decimal(, )
#  vertical_gain :decimal(, )
#  activity_date :datetime
#  sport         :string
#  user_id       :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  name          :string
#  external_id   :string
#  provider      :string
#

class Activity < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validate :metric_data_available
  validates :external_id, uniqueness: { scope: :provider }, if: :external_id?

  before_save :unit_conversion
  after_save :trigger_user_milestone_check

  STRAVA_UPDATEABLE_ATTRIBUTES = [:name, :sport, :activity_date, :distance, :vertical_gain]
  AFTER_EPOCH = "1514764800"
  PER_PAGE = 200

  # before save callback that ensures all `totals` are saved in miles
  # or feet
  def unit_conversion
    if user.metric_system?
      self.distance = Goal.kms_to_miles(distance) if distance.present?
      self.vertical_gain = Goal.meters_to_feet(vertical_gain) if vertical_gain.present?
    end
  end

  def converted_distance
    if distance?
      if user.imperial_system? or distance.blank?
        distance.try(:round, 2)
      else
        Goal.miles_to_kms(distance).round(2)
      end
    else
      nil
    end
  end

  def converted_vertical_gain
    if vertical_gain?
      if user.imperial_system? or vertical_gain.blank?
        vertical_gain.try(:round)
      else
        Goal.feet_to_meters(vertical_gain).round
      end
    else
      nil
    end
  end

  def self.update_or_create_from_strava(data)
    user = User.find_by(provider: 'strava', uid: data[:athlete][:id])

    activity = Activity.find_or_create_by(user: user, provider: 'strava', external_id: data[:id])

    # strava provides distance and total_elevation_gain in meters,
    # so we need to ensure this works properly
    if user.present? and user.metric_system? # conversion happens automatically on save
      activity.distance = data[:distance] / 1000 # make kms instead of ms
      activity.vertical_gain = data[:total_elevation_gain]
    else
      activity.distance = Goal.kms_to_miles(data[:distance] / 1000)
      activity.vertical_gain = Goal.meters_to_feet(data[:total_elevation_gain])
    end

    activity.name = data[:name] if data[:name].present?
    activity.sport = data[:type] if data[:type].present?
    activity.activity_date = DateTime.parse(data[:start_date]) if data[:start_date].present?

    activity.save!
    activity
  end

  def trigger_user_milestone_check
    user.update_milestones
  end

  private

  def metric_data_available
    if distance.blank? and vertical_gain.blank?
      errors.add(:base, "Specify at least one metric for your activity -- distance or vertical gain")
    end
  end
end
