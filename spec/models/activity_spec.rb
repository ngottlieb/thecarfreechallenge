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

require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'validate metric_data_available' do
    it "should not be valid without distance or vertical gain specified" do
      activity = FactoryBot.build(:activity, distance: nil, vertical_gain: nil)
      expect(activity).to_not be_valid
    end
  end
end
