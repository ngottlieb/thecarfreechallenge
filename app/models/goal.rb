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

class Goal < ApplicationRecord
  belongs_to :user

  METRICS_LABELS = {
    'distance' =>
      {
        'imperial' => 'miles',
        'metric' => 'kilometers'
      },
    'vertical_gain' =>
      {
        'imperial' => 'vertical feet',
        'metric' => 'meters'
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
end
