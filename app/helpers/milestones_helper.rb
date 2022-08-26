module MilestonesHelper
  def friendly_display_of_threshold(milestone, user)
    if milestone.metric_needs_conversion?
      label = Goal.metric_label(milestone.metric, user.measurement_system)
      if user.imperial_system?
        number = milestone.threshold.to_i
      else
        if milestone.metric == 'distance'
          number = Goal.miles_to_kms(milestone.threshold)
        elsif milestone.metric = 'vertical_gain'
          number = Goal.feet_to_meters(milestone.threshold)
        end
        number.round
      end

      return "#{number} #{label}"
    elsif milestone.metric == 'carbon'
      return "#{milestone.threshold} tons"
    elsif milestone.metric == 'combined'
      return "#{milestone.threshold} combined"
    else
      return milestone.threshold
    end
  end

  def exact_converted_display_of_threshold(milestone, user)
    if milestone.metric_needs_conversion?
      if user.imperial_system?
        number = milestone.threshold.to_i
      else
        if milestone.metric == 'distance'
          number = Goal.miles_to_kms(milestone.threshold)
        elsif milestone.metric = 'vertical_gain'
          number = Goal.feet_to_meters(milestone.threshold)
        end
      end
      return number
    else
      return milestone.threshold
    end
  end

  def milestone_achievement_verb(milestone)
    milestone.metric == 'distance' ? "traveled" : "gained"
  end

  def milestone_metrics_select_values(user)
    Milestone::METRICS.map do |metric|
      if metric == 'distance' || metric == 'vertical_gain'
        [Goal::METRICS_LABELS[metric][user.measurement_system], metric]
      elsif metric == 'carbon'
        ["tons of carbon", metric]
      else
        [metric, metric]
      end
    end
  end
end
