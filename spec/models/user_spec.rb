# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default("")
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  provider               :string
#  uid                    :string
#  name                   :string
#  measurement_system     :integer          default("imperial_system")
#  import_in_progress     :boolean          default(FALSE)
#  strava_access_token    :string
#  admin                  :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#start_of_earliest_goal' do
    let(:user) { FactoryBot.create :user }
    subject { user.start_of_earliest_goal }

    context 'with no goals' do
      it 'should return nil' do
        expect(subject).to eq nil
      end
    end

    context 'with goals' do
      let!(:goal1) { FactoryBot.create :goal, user: user, start_date: 1.year.ago }
      let!(:goal2) { FactoryBot.create :goal, user: user, start_date: 1.week.ago }

      it 'should return the beginning of the day of the earliest goal start_date' do
        expect(subject).to eq goal1.start_date.beginning_of_day
      end
    end
  end

  describe '#total_metric_in_date_range' do
    let(:user) { FactoryBot.create :user, measurement_system: :imperial_system }
    let(:metric) { 'vertical_gain' }
    let(:start_date) { nil }
    let(:end_date) { nil }

    subject { user.total_metric_in_date_range(metric: metric, start_date: start_date, end_date: end_date) }

    context 'with no activities' do
      it 'should return 0' do
        expect(subject).to eq 0
      end
    end

    context 'with activities' do
      let(:other_user) { FactoryBot.create :user }
      let!(:activity1) { FactoryBot.create :activity, activity_date: 1.week.ago, user: user }
      let!(:activity2) { FactoryBot.create :activity, activity_date: 4.days.ago, user: user }
      let!(:activity3) { FactoryBot.create :activity, activity_date: 4.weeks.ago, user: user }
      let!(:other_user_activity) { FactoryBot.create :activity, activity_date: 4.days.ago, user: other_user }
      let(:start_date) { 2.weeks.ago }
      let(:end_date) { 1.week.from_now }

      it 'should sum the metric for the user\'s activities within the date range' do
        expect(subject).to eq (activity1.send(metric) + activity2.send(metric))
      end

      context 'using the metric system' do
        let(:user) { FactoryBot.create :user, measurement_system: :metric_system }

        it 'should sum the metric for the user\'s activities within the date range' do
          expect(subject).to eq Goal.feet_to_meters((activity1.send(metric) + activity2.send(metric)))
        end
      end
    end
  end

  describe '#matching_milestones' do
    let(:user) { FactoryBot.create :user, measurement_system: :imperial_system }
    let!(:milestone) { FactoryBot.create :milestone, metric: Goal::METRICS_LABELS.keys[0], threshold: 10 }

    subject { user.matching_milestones }
    
    describe 'with no activities' do
      it 'should not assign any milestones' do
        expect(subject).to be_empty
      end
    end

    describe 'with activities totalling less than any available milestones' do
      let!(:activities) { FactoryBot.create_list :activity, 2, distance: 1, vertical_gain: 1, user: user }

      it 'should not assign any milestones' do
        expect(subject).to be_empty
      end
    end

    describe 'with combined activities totaling the threshold of an existing milestone' do
      let!(:activities) { FactoryBot.create_list :activity, 5, distance: 5, user: user }

      it 'should include any matched milestones' do
        expect(subject).to match_array([milestone])
      end
    end
  end

  describe '#update_milestones' do
    let!(:user) { FactoryBot.create :user, measurement_system: :imperial_system }
    let!(:milestone) { FactoryBot.create :milestone, metric: Goal::METRICS_LABELS.keys[0], threshold: 10 }

    subject { user.update_milestones }

    describe 'with no matching milestones' do
      before { allow(user).to receive(:matching_milestones).and_return([]) }

      it 'should leave the user milestones empty' do
        expect{ subject }.to_not change{ user.milestones }
      end
    end

    describe 'with a matching milestone' do
      before { allow(user).to receive(:matching_milestones).and_return([milestone]) }

      it 'should save the matching milestone' do
        expect{ subject }.to change{ user.reload.milestones }.to match_array([milestone])
      end

      it 'should send an email' do
        expect{ subject }.to enqueue_job( ActionMailer::MailDeliveryJob )
      end
    end
  end

end
