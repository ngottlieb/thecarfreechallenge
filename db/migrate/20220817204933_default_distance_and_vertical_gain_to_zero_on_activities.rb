class DefaultDistanceAndVerticalGainToZeroOnActivities < ActiveRecord::Migration[6.1]
  def change
    change_column_default :activities, :distance, from: nil, to: 0
    change_column_null :activities, :distance, false, 0
    change_column_default :activities, :vertical_gain, from: nil, to: 0
    change_column_null :activities, :vertical_gain, false, 0
  end
end
