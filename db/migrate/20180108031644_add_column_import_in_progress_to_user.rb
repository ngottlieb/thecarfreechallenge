class AddColumnImportInProgressToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :import_in_progress, :boolean, default: false
  end
end
