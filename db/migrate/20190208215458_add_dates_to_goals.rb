class AddDatesToGoals < ActiveRecord::Migration[5.1]
  def change
    add_column :goals, :start_date, :date
    add_column :goals, :end_date, :date
  end
end
