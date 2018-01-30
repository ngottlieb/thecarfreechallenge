feature 'Create a goal' do
  given(:user) { FactoryBot.create :user }
  background { login_as(user, scope: :user) }

  scenario 'creating a goal' do
    visit root_path
    click_link '+ Set a Goal'
    fill_in 'goal[total]', with: '1000'
    click_button 'Set Goal'
    expect(page).to have_content "1000 car-free"
  end

  scenario 'creating an invalid goal' do
    visit root_path
    click_link '+ Set a Goal'
    # don't fill in the total field
    click_button 'Set Goal'
    expect(page).to have_content 'There was an issue setting your goal'
  end

  context 'as a metric system user' do
    given(:user) { FactoryBot.create :user, measurement_system: :metric_system }
    background { login_as(user, scope: :user) }

    it 'should use metric system labels for new goals' do
      visit root_path
      click_link '+ Set a Goal'
      expect(page).to have_css('option[value="distance"]', text: 'kilometers')
    end

    # ensure that it displays the same thing the user input even though
    # in the background we're converting to imperial and back
    scenario 'creating a goal' do
      visit root_path
      click_link '+ Set a Goal'
      fill_in 'goal[total]', with: '1000'
      click_button 'Set Goal'
      expect(page).to have_content '1000 car-free'
    end
  end
end
