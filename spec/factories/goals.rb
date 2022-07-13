# == Schema Information
#
# Table name: goals
#
#  id         :bigint           not null, primary key
#  metric     :string
#  total      :decimal(, )
#  tag_line   :string
#  period     :string
#  public     :boolean
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  start_date :date
#  end_date   :date
#

FactoryBot.define do
  factory :goal do
    metric { Goal::METRICS_LABELS.keys[0] }
    tag_line { "MyString" }
    period { "MyString" }
    user
    total { 100000 }
  end
end
