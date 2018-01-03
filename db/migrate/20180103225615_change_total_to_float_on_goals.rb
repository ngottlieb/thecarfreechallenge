class ChangeTotalToFloatOnGoals < ActiveRecord::Migration[5.1]
  def change
    change_column :goals, :total, :float
  end
end
