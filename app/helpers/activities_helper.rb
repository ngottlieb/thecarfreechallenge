module ActivitiesHelper
  def display_distance(distance)
    if !current_user || current_user.imperial_system?
      number = distance
      measurement_system = "imperial_system"
    else
      number = Goal.miles_to_kms(distance)
      measurement_system = "metric_system"
    end

    return "#{number_with_delimiter number.round} #{Goal.metric_label('distance', measurement_system)}"
  end

  def display_vert(vert)
    if !current_user || current_user.imperial_system?
      number = vert
      measurement_system = "imperial_system"
    else
      number = Goal.feet_to_meters(vert)
      measurement_system = "metric_system"
    end

    return "#{number_with_delimiter number.round} #{Goal.metric_label('vertical_gain', measurement_system)}"
  end

  def emissions_given_distance(distance)
    tons = distance * 404 / 1000000
    "#{tons.round(2)} metric tons"
  end
end
