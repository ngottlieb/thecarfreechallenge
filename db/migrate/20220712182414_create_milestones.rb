class CreateMilestones < ActiveRecord::Migration[6.1]
  def change
    create_table :milestones do |t|
      t.string :metric
      t.decimal :threshold
      t.integer :created_by_id

      t.timestamps
    end

    create_table :milestones_users, id: false do |t|
      t.belongs_to :user
      t.belongs_to :milestone
    end
  end
end
