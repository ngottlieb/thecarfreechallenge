feature 'Login' do
  given(:user) { FactoryBot.create :user }
  background do
   visit root_path
   click_link 'Login'
  end

  scenario 'logging in with valid credentials' do
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Login'
    expect(page).to have_content 'Logout'
  end

  scenario 'logging in with invalid credentials' do
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'NOT THE PASSWORD'
    click_button 'Login'
    expect(page).to have_content 'Invalid'
  end

end
