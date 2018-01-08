require 'rails_helper'

RSpec.describe StravaImportJob, type: :job do

  describe 'perform' do
    let(:user) { FactoryBot.create :user, provider: 'strava', uid: '12345' }
    let(:access_token) { '1234567890' }
    let(:activity) { StravaTesting.example_activity(test_activity_params )}
    let(:test_activity_params) {
      {
        user_id: user.uid
      }
    }

    subject { StravaImportJob.perform_now(user, access_token) }

    before do
      allow(StravaService).to receive(:activities).and_return [activity]
    end

    it 'should call StravaService.activities' do
      expect(StravaService).to receive(:activities).with(user, access_token,{ after: Activity::AFTER_EPOCH, before: Activity::BEFORE_EPOCH })
      subject
    end

    it 'should update the user before and after execution' do
      expect(user).to receive(:update).twice
      subject
    end

    describe 'after execution is finished' do
      describe 'user.import_in_progress' do
        it 'should be false' do
          subject
          expect(user.reload.import_in_progress).to be false
        end
      end
    end

    context 'with a #carfreechallenge labeled activity' do
      let(:test_activity_params) {
        {
          user_id: user.uid,
          name: '#carfreechallenge activity'
        }
      }

      it 'should call Activity.update_or_create_from_strava' do
        expect(Activity).to receive(:update_or_create_from_strava).with(activity)
        subject
      end
    end

    context 'with a non #carfreechallenge labeled activity' do
      let(:test_activity_params) {
        {
          user_id: user.uid,
          name: 'THIS SPECIFICALLY DOES NOT CONTAIN THE HASH TAG'
        }
      }

      it 'should NOT call Activity.update_or_create_from_strava' do
        expect(Activity).to_not receive(:update_or_create_from_strava).with(any_args)
      end
    end

  end
  
end
