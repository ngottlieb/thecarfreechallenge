class UpdateMilestonesJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      user.update_milestones
    end
  end
end