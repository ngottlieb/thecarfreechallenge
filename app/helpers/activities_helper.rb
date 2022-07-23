module ActivitiesHelper
  def display_distance(distance)
    if current_user.imperial_system?
      number = distance
    else
      number = Goal.miles_to_kms(distance)
    end

    return "#{number_with_delimiter number.round} #{Goal.metric_label('distance', current_user.measurement_system.to_s)}"
  end

  def display_vert(vert)
    if current_user.imperial_system?
      number = vert
    else
      number = Goal.feet_to_meters(vert)
    end

    return "#{number_with_delimiter number.round} #{Goal.metric_label('vertical_gain', current_user.measurement_system.to_s)}"
  end

  def emissions_given_distance(distance)
    tons = distance * 404 / 1000000
    "#{tons.round(2)} tons"
  end
end
