FactoryBot.define do
  factory :activity do
    distance 100
    vertical_gain 1000
    activity_date "2017-12-30 13:32:30"
    sport "trail_running"
    user
  end
end
