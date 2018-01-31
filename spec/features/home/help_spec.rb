feature 'Help page' do
  given(:user) { FactoryBot.create :user }
  background { login_as(user, scope: :user) }

  scenario 'visit the help page' do
    visit help_path
    expect(page).to have_content 'Want to Help?'
  end
end
