# == Schema Information
#
# Table name: activities
#
#  id            :bigint           not null, primary key
#  distance      :decimal(, )
#  vertical_gain :decimal(, )
#  activity_date :datetime
#  sport         :string
#  user_id       :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  name          :string
#  external_id   :string
#  provider      :string
#

FactoryBot.define do
  factory :activity do
    distance { 100 }
    vertical_gain { 1000 }
    activity_date { DateTime.parse("2018-01-25") }
    sport { "trail_running" }
    user
  end
end
