class AddStravaAccessTokenToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :strava_access_token, :string
  end
end
