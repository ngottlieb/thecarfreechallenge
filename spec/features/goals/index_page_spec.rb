feature 'Goals page' do

  context 'as an anonymous user' do
    scenario 'visit the goals page' do
      visit goals_path
      # should be redirected to login page
      expect(page).to have_content 'Login'
    end
  end

  context 'as a logged in user' do
    given(:user) { FactoryBot.create :user }
    background { login_as(user, scope: :user) }

    scenario 'visit the goals page' do
      visit goals_path
      expect(page).to have_css('input[value="Set Goal"][type="submit"]')
    end

    context 'with existing goals' do
      given!(:goal) { FactoryBot.create :goal, user: user }

      feature 'visit the goals page' do
        background { visit goals_path }

        it 'should display the goal' do
          expect(page).to have_content "#{goal.converted_total} human-powered #{goal.metric_label}"
        end

        it 'should display the goal sharing button' do
          expect(page).to have_link 'Share Your Goal'
        end
      end
    end

    scenario 'creating a goal' do
      visit goals_path
      fill_in 'goal[total]', with: '1000'
      click_button 'Set Goal'
      expect(page).to have_content "1000 human-powered"
    end

    scenario 'creating an invalid goal' do
      visit goals_path
      # don't fill in the total field
      click_button 'Set Goal'
      expect(page).to have_content 'There was an issue setting your goal'
    end

    context 'as a metric system user' do
      given(:user) { FactoryBot.create :user, measurement_system: :metric_system }
      background { login_as(user, scope: :user) }

      it 'should use metric system labels for new goals' do
        visit goals_path
        expect(page).to have_css('option[value="distance"]', text: 'kilometers')
      end

      # ensure that it displays the same thing the user input even though
      # in the background we're converting to imperial and back
      scenario 'creating a goal' do
        visit goals_path
        fill_in 'goal[total]', with: '1000'
        click_button 'Set Goal'
        expect(page).to have_content '1000 human-powered'
      end
    end

  end
end
