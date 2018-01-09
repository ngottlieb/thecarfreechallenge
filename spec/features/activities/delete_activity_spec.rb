feature 'Delete an activity' do
  given(:user) { FactoryBot.create :user }
  given!(:activity) { FactoryBot.create :activity, user: user }
  background do
    login_as(user, scope: :user)
    visit activities_path
  end

  scenario 'clicking delete on an activity' do
    find(".delete-activity-#{activity.id}").click
    expect(page).to_not have_css('tr', class: "activity-#{activity.id}")
  end
end
