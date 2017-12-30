class AddMeasurementSystemToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :measurement_system, :string, default: 'imperial'
  end
end
