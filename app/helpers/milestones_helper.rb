module MilestonesHelper
  def friendly_display_of_threshold(milestone, user)
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
  end

  def milestone_achievement_verb(milestone)
    milestone.metric == 'distance' ? "traveled" : "gained"
  end
end
