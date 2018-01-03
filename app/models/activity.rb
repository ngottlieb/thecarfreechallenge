# == Schema Information
#
# Table name: activities
#
#  id            :integer          not null, primary key
#  distance      :integer
#  vertical_gain :integer
#  activity_date :datetime
#  sport         :string
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Activity < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validate :metric_data_available

  before_save :unit_conversion

  # before save callback that ensures all `totals` are saved in miles
  # or feet
  def unit_conversion
    if user.metric_system?
      self.distance = Goal.kms_to_miles(distance) if distance.present?
      self.vertical_gain = Goal.meters_to_feet(vertical_gain) if vertical_gain.present?
    end
  end

  def converted_distance
    if user.imperial_system? or distance.blank?
      distance
    else
      Goal.miles_to_kms(distance).round
    end
  end

  def converted_vertical_gain
    if user.imperial_system? or vertical_gain.blank?
      vertical_gain
    else
      Goal.feet_to_meters(vertical_gain).round
    end
  end

  private

  def metric_data_available
    if distance.blank? and vertical_gain.blank?
      errors.add(:base, "Specify at least one metric for your activity -- distance or vertical gain")
    end
  end
end
