feature 'Create a milestone' do
  background { login_as(user, scope: :user) }

  context 'as a user who is not an admin' do
    given(:user) { FactoryBot.create :user, admin: false }

    it 'should not show create milestone link' do
      visit milestones_path
      expect(page).to_not have_link 'Create a New Milestone'
    end
  end

  context 'as a user who is an admin' do
    given(:user) { FactoryBot.create :user, admin: true }

    scenario 'creating a milestone' do
      visit milestones_path
      click_link 'Create a New Milestone', match: :first
      fill_in 'milestone[threshold]', with: '1000'
      click_button 'Submit'
      expect(page).to have_selector('table#milestoneTable tbody tr')
    end

    context 'as a user who uses the metric system' do
      given(:user) { FactoryBot.create :user, admin: true, measurement_system: :metric_system }

      context 'creating a milestone' do
        given(:threshold) { 100 }

        before do
          visit milestones_path
          click_link 'Create a New Milestone', match: :first
          fill_in 'milestone[threshold]', with: threshold
          select 'kilometers', from: 'milestone[metric]'
          click_button 'Submit'
        end

        it 'should save the milestone with imperial units' do
          expect(Milestone.last.threshold).to eq Goal.kms_to_miles(threshold)
        end
      end
    end

    context 'with activities completing the milestone' do
      include ActiveJob::TestHelper

      given!(:activities) { FactoryBot.create_list :activity, 3, user: user, distance: 10 }

      # NOTE: this requires testing with active job queue adapter :inline
      # if suite-wide config changes to test adapter in the future,
      # will need to add a custom flag to allow inline testing
      context 'creating a milestone' do
        before do
          perform_enqueued_jobs do
            visit milestones_path
            click_link 'Create a New Milestone', match: :first
            fill_in 'milestone[threshold]', with: '10'
            select 'miles', from: 'milestone[metric]'
            click_button 'Submit'
          end
        end

        it 'should show the milestone achieved' do
          expect(page).to have_selector('table#milestoneTable svg')    
        end

        it 'should show the count of users who have achieved the milestone' do
          expect(page.all('table#milestoneTable tr td')[1]).to have_content '1'
        end
      end
    end
  end
end