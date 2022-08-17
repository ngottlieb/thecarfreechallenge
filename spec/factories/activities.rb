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
    distance { Random.random_number(50) }
    vertical_gain { Random.random_number(3000) }
    activity_date { DateTime.parse("2018-01-25") }
    sport { "trail_running" }
    user
  end
end
