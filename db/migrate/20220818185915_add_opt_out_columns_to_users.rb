class AddOptOutColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :opt_out_of_leaderboard, :boolean, default: false
    add_column :users, :opt_out_of_barueat_emails, :boolean, default: false
  end
end
