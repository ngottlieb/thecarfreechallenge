feature 'Milestones index page' do
  context 'as an anonymous user' do
    background { visit milestones_path }
    scenario 'visit the milestones page' do
      # should be redirected to login
      expect(page).to have_content 'Login'
    end
  end

  context 'as a logged in user' do
    given!(:milestones) { FactoryBot.create_list :milestone, 3, metric: 'distance' }
    given(:user) { FactoryBot.create :user }

    background do
      login_as(user, scope: :user)
      visit milestones_path
    end

    it 'should display the available milestones' do
      expect(all('table#milestoneTable tbody tr').count).to eq 3
    end

    context 'using the metric system' do
      given(:user) { FactoryBot.create :user, measurement_system: :metric_system }

      it 'should display the milestones in metric' do
        milestones.each do |m|
          expect(page).to have_content(Goal.miles_to_kms(m.threshold))
        end
      end
    end
  end
end