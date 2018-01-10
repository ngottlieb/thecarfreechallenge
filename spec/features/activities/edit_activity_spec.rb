feature 'Edit an activity' do
  given(:user) { FactoryBot.create :user }
  given!(:activity) { FactoryBot.create :activity, user: user, sport: 'TrailRun' }
  background do
    login_as(user, scope: :user)
    visit activities_path
  end

  scenario 'editing an activity with valid changes' do
    find(".edit-activity-#{activity.id}").click
    fill_in "activity[sport]", with: "NordicSki"
    click_button "Submit"
    expect(page.find("tr.activity-#{activity.id}")).to have_content "NordicSki"
  end
end
