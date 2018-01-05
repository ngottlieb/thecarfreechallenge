feature 'Log an activity' do
  given(:user) { FactoryBot.create :user }
  background { login_as(user, scope: :user) }

  scenario 'creating a valid activity' do
    visit activities_path
    click_link '+ Log an activity'
    txt = '100'
    fill_in 'activity[distance]', with: txt
    click_button 'Submit'
    expect(page).to have_css('td', text: txt)
  end

  scenario 'creating an invalid activity' do
    visit activities_path
    click_link '+ Log an activity'
    click_button 'Submit'
    expect(page).to have_content 'error'
  end

  context 'for a metric user' do
    given(:user) { FactoryBot.create :user, measurement_system: :metric_system }

    # input a value in the metric format and ensure it shows up
    # as the same number on the index page
    scenario 'creating an activity' do
      visit activities_path
      click_link '+ Log an activity'
      txt = '100'
      fill_in 'activity[vertical_gain]', with: txt
      click_button 'Submit'
      expect(page).to have_css('td', text: txt)
    end
  end

end
