feature 'Delete a goal' do
  given(:user) { FactoryBot.create :user }
  given!(:goal) { FactoryBot.create :goal, user: user }
  background do
    login_as(user, scope: :user)
    visit root_path
  end

  scenario 'editing a goal' do
    find(".goal-#{goal.id}").find_link('Edit').click
    fill_in 'goal[total]', with: "12345"
    click_button 'Set Goal'
    expect(page).to have_content "12345 car-free"
  end
end
