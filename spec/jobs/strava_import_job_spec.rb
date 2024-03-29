require 'rails_helper'

RSpec.describe StravaImportJob, type: :job do

  describe 'perform' do
    let(:user) { FactoryBot.create :user, provider: 'strava', uid: '12345' }
    let(:activity) { StravaTesting.example_activity(test_activity_params)}
    let(:test_activity_params) {
      {
        user_id: user.uid
      }
    }

    subject { StravaImportJob.perform_now(user) }

    before do
      allow(StravaService).to receive(:activities).and_return [activity]
    end

    it 'should call StravaService.activities' do
      expect(StravaService).to receive(:activities).with(user,{ after: Activity::AFTER_EPOCH,
                                                                              per_page: Activity::PER_PAGE, page: 1  })
      subject
    end

    describe 'perform_later' do
      subject { StravaImportJob.perform_later(user) }

      it "set the user's import_in_progress flag when enqueued" do
        expect{ subject }.to change{ user.import_in_progress }.to true
      end
    end

    describe "with more than #{Activity::PER_PAGE} activities" do
      before do
        first_page = []
        Activity::PER_PAGE.times do
          first_page += [StravaTesting.example_activity(test_activity_params)]
        end
        @car_free_activity = StravaTesting.example_activity(test_activity_params.merge({ name: '#carfreechallenge activity' }))
        second_page = [@car_free_activity]
        allow(StravaService).to receive(:activities).with(user, first_page_params).and_return(first_page)
        allow(StravaService).to receive(:activities).with(user, second_page_params).and_return(second_page)
      end

      let(:first_page_params) { { after: Activity::AFTER_EPOCH, per_page: Activity::PER_PAGE, page: 1 } }
      let(:second_page_params) { { after: Activity::AFTER_EPOCH, per_page: Activity::PER_PAGE, page: 2 } }

      it 'should call StravaService twice' do
        expect(StravaService).to receive(:activities).with(user, first_page_params)
        expect(StravaService).to receive(:activities).with(user, second_page_params)
        subject
      end

      it 'should call Activity.update_or_create_from_strava with the second page activity' do
        expect(Activity).to receive(:update_or_create_from_strava).with(@car_free_activity)
        subject
      end
    end

    describe 'with a goal with a start_date' do
      let(:start_date) { 4.weeks.ago }
      let!(:goal) { FactoryBot.create :goal, user: user, start_date: start_date }

      it 'should use the minimum start_date as the `after` parameter' do
        expect(StravaService).to receive(:activities).with(user,
                                                           { after: start_date.beginning_of_day.to_i, per_page: Activity::PER_PAGE, page: 1 })
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

    Activity::STRAVA_HASHTAG_MATCHERS.each do |tag|
      context "with an activity matching #{tag}" do
        let(:test_activity_params) {
          {
            user_id: user.uid,
            name: "#{tag} activity"
          }
        }

        it 'should call Activity.update_or_create_from_strava' do
          expect(Activity).to receive(:update_or_create_from_strava).with(activity)
          subject
        end
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
