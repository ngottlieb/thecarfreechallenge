# == Schema Information
#
# Table name: goals
#
#  id         :integer          not null, primary key
#  metric     :string
#  total      :integer
#  tag_line   :string
#  period     :string
#  public     :boolean
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# NOTE: "total" and "metric" are *always* stored in the database
# as imperial system data. They are converted to appropriate
# metric system labels and numbers for users who specify that they
# are using the metric system.

class Goal < ApplicationRecord
  belongs_to :user

  before_save :unit_conversion

  validates_presence_of :total, :metric

  METRICS_LABELS = {
    'distance' =>
      {
        'imperial_system' => 'miles',
        'metric_system' => 'kilometers'
      },
    'vertical_gain' =>
      {
        'imperial_system' => 'vertical feet',
        'metric_system' => 'vertical meters'
      }
    }

  def self.metrics_select_values(user)
    METRICS_LABELS.keys.map do |metric|
      [METRICS_LABELS[metric][user.measurement_system], metric]
    end
  end

  def self.metric_label(metric, measurement_system)
    METRICS_LABELS[metric][measurement_system]
  end

  def metric_label
    METRICS_LABELS[metric][user.measurement_system]
  end

  # returns progress towards goal %
  def progress
    result = user.total_metric_in_date_range(metric)*100 / total
    result > 100 ? 100 : result
  end

  # before save callback that ensures all `totals` are saved in miles
  # or feet
  def unit_conversion
    if user.metric_system?
      old_total = self.total
      if metric == 'distance'
        self.total = Goal.kms_to_miles(old_total)
      elsif metric == 'vertical_gain'
        self.total = Goal.meters_to_feet(old_total)
      end
    end
  end

  def converted_total
    if user.imperial_system?
      total.to_i
    else
      if metric == 'distance'
        output = Goal.miles_to_kms(total)
      elsif metric == 'vertical_gain'
        output = Goal.feet_to_meters(total)
      end
      output.round
    end
  end

  # these are purposely *slightly* rough
  def self.feet_to_meters(feet)
    feet.to_d / 3.28
  end

  def self.meters_to_feet(meters)
    meters.to_d * 3.28
  end

  def self.miles_to_kms(miles)
    miles.to_d * 1.6
  end

  def self.kms_to_miles(kms)
    kms.to_d / 1.6
  end
end
