module MilestonesHelper
  def friendly_display_of_threshold(milestone)
    label = Goal.metric_label(milestone.metric, current_user.measurement_system)
    if current_user.imperial_system?
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
  end
end
