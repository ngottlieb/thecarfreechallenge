class ChangeFloatsToDecimals < ActiveRecord::Migration[5.1]
  def up
    change_column :goals, :total, :decimal
    change_column :activities, :distance, :decimal
    change_column :activities, :vertical_gain, :decimal
  end

  def down
    change_column :goals, :total, :float
    change_column :activities, :distance, :float
    change_column :activities, :vertical_gain, :float
  end
end
