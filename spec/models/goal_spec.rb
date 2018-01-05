# == Schema Information
#
# Table name: goals
#
#  id         :integer          not null, primary key
#  metric     :string
#  total      :integer
#  tag_line   :string
#  period     :string
#  public     :boolean
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Goal, type: :model do
  describe 'Goal.metrics_select_values(user)' do
    User.measurement_systems.keys.each do |system|
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

  describe 'unit_conversion' do
    let(:goal) { FactoryBot.build :goal, user: user }

    subject { goal.unit_conversion }

    context 'with an imperial system user' do
      let(:user) { FactoryBot.create :user, measurement_system: :imperial_system }

      it 'should do nothing' do
        expect{subject}.to_not change{goal.total}
      end
    end

    context 'with a metric system user' do
      let(:user) { FactoryBot.create :user, measurement_system: :metric_system }

      it 'should change `total`' do
        expect{subject}.to change{goal.total}
      end

      context 'with a distance metric' do
        let(:total) { 1000 }
        let(:goal) { FactoryBot.build :goal, user: user, metric: 'distance', total: total }

        it 'should correctly convert `total` to miles from kms' do
          expect{subject}.to change{goal.total}.from(total).to(Goal.kms_to_miles(total))
        end
      end

      context 'with a vertical_gaiin metric' do
        let(:total) { 1000 }
        let(:goal) { FactoryBot.build :goal, user: user, metric: 'vertical_gain', total: total }

        it 'should correctly convert `total` to miles from kms' do
          expect{subject}.to change{goal.total}.from(total).to(Goal.meters_to_feet(total))
        end
      end
    end

    describe 'as before_save callback' do
      describe 'for metric user' do
        let(:user) { FactoryBot.create :user, measurement_system: :metric_system }

        it 'should save the record with the modified units' do
          original_total = goal.total
          goal.save
          expect(goal.reload.total).to_not eq original_total
        end
      end

      describe 'for imperial user' do
        let(:user) { FactoryBot.create :user, measurement_system: :imperial_system }

        it 'should save the record with original units' do
          original_total = goal.total
          goal.save
          expect(goal.reload.total).to eq original_total
        end
      end
    end
  end

  describe 'converted_total' do
    let(:goal) { FactoryBot.create :goal, user: user, metric: metric, total: total }
    let(:metric) { 'distance' }
    let(:total) { 1000 }
    subject { goal.converted_total }

    context 'for an imperial user' do
      let(:user) { FactoryBot.create :user, measurement_system: :imperial_system }

      it 'should return the unmodified value' do
        expect(subject).to eq goal.total.round
      end
    end

    context 'for a metric user' do
      let(:user) { FactoryBot.create :user, measurement_system: :metric_system }

      context 'with a distance metric' do
        it 'should return the database value converted to kilometers' do
          expect(subject).to eq Goal.miles_to_kms(goal.total).round
        end
      end

      context 'with a vertical_gain metric' do
        let(:metric) { 'vertical_gain' }
        it 'should return the database value converted to meters' do
          expect(subject).to eq Goal.feet_to_meters(goal.total).round
        end
      end
    end
  end

  describe 'progress' do
    let(:user) { FactoryBot.create :user }
    before do
      allow(user).to receive(:total_metric_in_date_range).with(goal.metric).and_return(user_total)
    end
    let(:goal) { FactoryBot.create :goal, user: user }

    subject { goal.progress }

    context 'if the user has not completed the goal' do
      let(:user_total) { perc * goal.total }
      let(:perc) { 0.5 }

      it 'should return the percentage they have completed' do
        expect(subject).to eq perc*100
      end
    end

    context 'if the user has completed the goal' do
      let(:user_total) { goal.total + 100 }

      it 'should return 100' do
        expect(subject).to eq 100
      end
    end
  end
end
