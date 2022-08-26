class AddTaglineToMilestones < ActiveRecord::Migration[6.1]
  def change
    add_column :milestones, :tagline, :string
  end
end
