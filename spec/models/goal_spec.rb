require 'rails_helper'

RSpec.describe Goal, type: :model do
  describe 'Goal.metrics_select_values(user)' do
    ['imperial', 'metric'].each do |system|
      context "with a #{system} user" do
        let(:user) { FactoryBot.create :user, measurement_system: system }
        subject { Goal.metrics_select_values(user) }

        it "should return the correct vertical_gain / distance select options" do
          expect(subject).to match_array([
            [Goal::METRICS_LABELS['distance'][user.measurement_system], 'distance'],
            [Goal::METRICS_LABELS['vertical_gain'][user.measurement_system], 'vertical_gain'],
          ])
        end
      end
    end
  end  
end
