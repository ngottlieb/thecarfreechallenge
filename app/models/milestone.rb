# == Schema Information
#
# Table name: milestones
#
#  id            :bigint           not null, primary key
#  metric        :string
#  threshold     :decimal(, )
#  created_by_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Milestone < ApplicationRecord
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id', optional: true
  has_and_belongs_to_many :users

  validates_presence_of :threshold, :metric
  
  before_save :unit_conversion
  after_save :trigger_update_milestones_job

  has_one_attached :badge

  # before save callback that ensures all `totals` are saved in miles
  # or feet
  # assumes incoming units are the created_by user's
  def unit_conversion
    if created_by.try(:metric_system?)
      old_threshold = self.threshold
      if metric == 'distance'
        self.threshold = Goal.kms_to_miles(old_threshold)
      elsif metric == 'vertical_gain'
        self.threshold = Goal.meters_to_feet(old_threshold)
      end
    end
  end

  def trigger_update_milestones_job
    UpdateMilestonesJob.perform_later
  end
end
