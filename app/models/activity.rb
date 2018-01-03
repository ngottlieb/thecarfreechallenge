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

  private

  def metric_data_available
    if distance.blank? and vertical_gain.blank?
      errors.add(:base, "Specify at least one metric for your activity -- distance or vertical gain")
    end
  end
end
