class AddStravaRefreshTokenToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :strava_refresh_token, :string
  end
end
