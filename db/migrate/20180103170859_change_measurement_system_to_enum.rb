class ChangeMeasurementSystemToEnum < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :measurement_system
    add_column :users, :measurement_system, :integer, default: User.measurement_systems[:imperial_system]
  end
end
