class ChangeMeasurementSystemToEnum < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :measurement_system, :old_measurement_system
    add_column :users, :measurement_system, :integer, default: User.measurement_systems[:imperial_system]

    # transfer data from old column
    User.all.each do |u|
      u.measurement_system = u.old_measurement_system + '_system'
      u.save!
    end

    remove_column :users, :old_measurement_system
  end
end
