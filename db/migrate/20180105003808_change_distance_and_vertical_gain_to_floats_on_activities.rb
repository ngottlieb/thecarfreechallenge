class ChangeDistanceAndVerticalGainToFloatsOnActivities < ActiveRecord::Migration[5.1]
  def change
    change_column :activities, :distance, :float
    change_column :activities, :vertical_gain, :float
  end
end
