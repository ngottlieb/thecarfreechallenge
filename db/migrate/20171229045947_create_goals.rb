class CreateGoals < ActiveRecord::Migration[5.1]
  def change
    create_table :goals do |t|
      t.string :metric
      t.integer :total
      t.string :tag_line
      t.string :period
      t.boolean :public
      t.integer :user_id

      t.timestamps
    end
  end
end
