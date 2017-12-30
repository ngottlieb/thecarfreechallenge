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
