class AddOptOutOfMilestoneNotificationsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :opt_out_of_milestone_notifications, :boolean, default: false
  end
end
