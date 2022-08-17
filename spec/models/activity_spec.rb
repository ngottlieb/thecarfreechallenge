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

require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe 'validate metric_data_available' do
    it "should not be valid without distance or vertical gain specified" do
      activity = FactoryBot.build(:activity, distance: nil, vertical_gain: nil)
      expect(activity).to_not be_valid
    end
  end

  describe 'converted_distance' do
    let(:activity) { FactoryBot.create :activity, user: user }
    let(:user) { FactoryBot.create :user, measurement_system: system }
    let(:system) { :imperial_system }

    subject { activity.converted_distance }

    context 'when distance is blank' do
      before { activity.distance = nil }

      it 'should return the value unchanged' do
        expect(subject).to eq activity.distance
      end
    end

    context 'with an imperial system user' do
      let(:system) { :imperial_system }

      it 'should return the value unchanged' do
        expect(subject).to eq activity.distance
      end
    end

    context 'with a metric system uesr' do
      let(:system) { :metric_system }

      it 'should return the value converted to kilometers and rounded' do
        expect(subject).to eq Goal.miles_to_kms(activity.distance).round
      end
    end
  end

  describe 'converted_vertical_gain' do
    let(:activity) { FactoryBot.create :activity, user: user }
    let(:user) { FactoryBot.create :user, measurement_system: system }
    let(:system) { :imperial_system }

    subject { activity.converted_vertical_gain }

    context 'when vertical_gain is blank' do
      before { activity.vertical_gain = nil }

      it 'should return the value unchanged' do
        expect(subject).to eq activity.vertical_gain
      end
    end

    context 'with an imperial system user' do
      let(:system) { :imperial_system }

      it 'should return the value unchanged' do
        expect(subject).to eq activity.vertical_gain
      end
    end

    context 'with a metric system uesr' do
      let(:system) { :metric_system }

      it 'should return the value converted to meters and rounded' do
        expect(subject).to eq Goal.feet_to_meters(activity.vertical_gain).round
      end
    end
  end

  describe 'unit_conversion' do
    let(:activity) { FactoryBot.build :activity, user: user, distance: dist, vertical_gain: vert }
    let(:dist) { rand(100) }
    let(:vert) { rand(2000) }
    subject { activity.unit_conversion }

    context 'with an imperial system user' do
      let(:user) { FactoryBot.create :user, measurement_system: :imperial_system }

      it 'should do nothing to the distance' do
        expect{subject}.to_not change{activity.distance}
      end

      it 'should do nothing to the vertical_gain' do
        expect{subject}.to_not change{activity.vertical_gain}
      end
    end

    context 'with a metric system user' do
      let(:user) { FactoryBot.create :user, measurement_system: :metric_system }

      it 'should convert distance to miles' do
        expect{subject}.to change{activity.distance}.to(Goal.kms_to_miles(dist))
      end

      it 'should convert vertical_gain to feet' do
        expect{subject}.to change{activity.vertical_gain}.to(Goal.meters_to_feet(vert))
      end
    end

    describe 'as before_save callback' do
      describe 'for metric user' do
        let(:user) { FactoryBot.create :user, measurement_system: :metric_system }

        it 'should save the record with the modified distance' do
          original_distance = activity.distance
          activity.save
          expect(activity.reload.distance).to_not eq original_distance
        end

        it 'should save the record with the modified vertical gain' do
          original_vert = activity.vertical_gain
          activity.save
          expect(activity.reload.vertical_gain).to_not eq original_vert
        end
      end

      describe 'for imperial user' do
        let(:user) { FactoryBot.create :user, measurement_system: :imperial_system }

        it 'should not modify the distance when saving' do
          original_distance = activity.distance
          activity.save
          expect(activity.reload.distance).to eq original_distance
        end

        it 'should not modify the vertical_gain when saving' do
          original_vert = activity.vertical_gain
          activity.save
          expect(activity.reload.vertical_gain).to eq original_vert
        end
      end

    end
  end

  describe 'Activity.from_strava' do
    subject { Activity.update_or_create_from_strava(strava_data) }

    context 'with no matching user' do
      let(:strava_data) { StravaTesting.example_activity }

      it 'should raise a validation error' do
        expect{subject}.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'with a valid user' do
      let(:user) { FactoryBot.create :user, provider: 'strava', uid: rand(100000),
        measurement_system: system }
      let(:system) { :imperial_system }
      let(:strava_data) { StravaTesting.example_activity(user_id: user.uid) }

      it 'should create a valid activity' do
        expect{subject}.to change{user.activities.count}.by(1)
      end

      # it should be saved in feet / miles regardless, and it's given in meters regardless,
      # so the tests are the same, but the code handling it is different, so we're testing both
      # scenarios
      [:metric_system, :imperial_system].each do |sys|
        context "who uses the #{sys}" do
          let(:system) { sys }
          it 'should save vertical_gain accurately' do
            expect(subject.reload.vertical_gain).to eq Goal.meters_to_feet(strava_data.total_elevation_gain)
          end
          it 'should save distance accurately' do
            expect(subject.reload.distance).to eq Goal.kms_to_miles(strava_data.distance / 1000)
          end
        end
      end

      context 'with an existing activity' do
        let!(:activity) { FactoryBot.create :activity, user: user, provider: 'strava',
          external_id: strava_data.id, name: 'fake name but not the same as the strava name' }

        it 'should not create a new activity' do
          expect{subject}.to_not change{user.activities.count}
        end

        Activity::STRAVA_UPDATEABLE_ATTRIBUTES.each do |attr|
          it "should update #{attr} on the existing activity" do
            expect{subject}.to change{activity.reload.send(attr)}
          end
        end
      end
    end

  end
end
