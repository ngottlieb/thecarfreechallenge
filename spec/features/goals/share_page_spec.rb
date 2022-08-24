feature 'Share goal' do
  context 'as an anonymous user' do
    given(:goal) { FactoryBot.create :goal }

    scenario 'visit a goal share page' do
      visit goal_path(goal)
      expect(page).to have_content "#{goal.user.name} has pledged to travel"
    end

    context 'with a metric user having created the goal' do
      given(:user) { FactoryBot.create :user, measurement_system: :metric_system }
      given(:goal_in_meters) { 900 }
      given(:goal) { FactoryBot.create :goal, user: user, total: goal_in_meters, metric: :vertical_gain }

      scenario 'visit a goal share page' do
        visit goal_path(goal)
        expect(page).to have_content "#{goal.user.name} has pledged to travel #{goal_in_meters} human-powered vertical meters"
      end
    end
  end

  context 'as a logged in user' do
    given(:user) { FactoryBot.create :user }
    given!(:goal) { FactoryBot.create :goal, user: user }

    background do
      login_as(user, scope: :user)
      visit dashboard_path
      find(".goal").click_link 'Share'
    end

    it 'should display the username and goal' do
      expect(page).to have_content "#{goal.user.name} has pledged to travel"
    end
  end
end
