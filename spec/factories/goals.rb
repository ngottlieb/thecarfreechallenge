FactoryBot.define do
  factory :goal do
    metric Goal::METRICS_LABELS.keys[0]
    tag_line "MyString"
    period "MyString"
    public false
    user
    total 100000
  end
end
