feature 'Delete a goal' do
  given(:user) { FactoryBot.create :user }
  given!(:goal) { FactoryBot.create :goal, user: user }
  background do
    login_as(user, scope: :user)
    visit root_path
  end

  scenario 'clicking delete on a goal' do
    find(".goal-#{goal.id}").find_link('Delete').click
    expect(page).to_not have_css("goal-#{goal.id}")
  end
end
