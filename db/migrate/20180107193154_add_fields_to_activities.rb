class AddFieldsToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :activities, :name, :string
    add_column :activities, :external_id, :string
    add_column :activities, :provider, :string

    add_index :activities, [:provider, :external_id], unique: true
  end
end
