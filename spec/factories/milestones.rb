# == Schema Information
#
# Table name: milestones
#
#  id            :bigint           not null, primary key
#  metric        :string
#  threshold     :decimal(, )
#  created_by_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :milestone do
    metric { Goal::METRICS_LABELS.keys[0] }
    threshold { 100 }
  end
end
