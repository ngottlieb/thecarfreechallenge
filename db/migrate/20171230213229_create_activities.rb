class CreateActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities do |t|
      t.integer :distance
      t.integer :vertical_gain
      t.datetime :activity_date
      t.string :sport
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
