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
      expect(StravaService).to receive(:activities).with(user, access_token,{ after: Activity::AFTER_EPOCH, before: Activity::BEFORE_EPOCH,
                                                                              per_page: Activity::PER_PAGE, page: 1  })
      subject
    end

    it 'should update the user before and after execution' do
      expect(user).to receive(:update).twice
      subject
    end

    describe "with more than #{Activity::PER_PAGE} activities" do
      before do
        first_page = []
        Activity::PER_PAGE.times do
          first_page += [StravaTesting.example_activity(test_activity_params)]
        end
        @car_free_activity = StravaTesting.example_activity(test_activity_params.merge({ name: '#carfreechallenge activity' }))
        second_page = [@car_free_activity]
        allow(StravaService).to receive(:activities).with(user, access_token, first_page_params).and_return(first_page)
        allow(StravaService).to receive(:activities).with(user, access_token, second_page_params).and_return(second_page)
      end

      let(:first_page_params) { { after: Activity::AFTER_EPOCH, before: Activity::BEFORE_EPOCH, per_page: Activity::PER_PAGE, page: 1 } }
      let(:second_page_params) { { after: Activity::AFTER_EPOCH, before: Activity::BEFORE_EPOCH, per_page: Activity::PER_PAGE, page: 2 } }

      it 'should call StravaService twice' do
        expect(StravaService).to receive(:activities).with(user, access_token, first_page_params)
        expect(StravaService).to receive(:activities).with(user, access_token, second_page_params)
        subject
      end

      it 'should call Activity.update_or_create_from_strava with the second page activity' do
        expect(Activity).to receive(:update_or_create_from_strava).with(@car_free_activity)
        subject
      end
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
