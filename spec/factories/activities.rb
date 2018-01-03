# == Schema Information
#
# Table name: activities
#
#  id            :integer          not null, primary key
#  distance      :integer
#  vertical_gain :integer
#  activity_date :datetime
#  sport         :string
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :activity do
    distance 100
    vertical_gain 1000
    activity_date "2017-12-30 13:32:30"
    sport "trail_running"
    user
  end
end
