require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'validate metric_data_available' do
    it "should not be valid without distance or vertical gain specified" do
      activity = FactoryBot.build(:activity, distance: nil, vertical_gain: nil)
      expect(activity).to_not be_valid
    end
  end
end
