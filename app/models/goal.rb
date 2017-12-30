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

  def metric_label
    METRICS_LABELS[metric][user.measurement_system]
  end

  # returns progress towards goal %
  def progress
    # stub, needs to calculate progress
    25
  end
end
