feature 'Unsubscribe' do
  given(:user) { FactoryBot.create :user }

  scenario 'Visiting unsubscribe URL' do
    visit unsubscribe_path(id: user.id)
    expect(page).to have_content "no longer receive emails"
  end
end