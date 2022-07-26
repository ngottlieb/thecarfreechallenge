feature 'Signup' do
  background do
    visit root_path
    find('.navbar').click_link "Sign up"
  end

  scenario 'click the sign up link' do
    expect(page).to have_css('input[type="submit"][value="Sign up"]')
  end

  scenario 'sign up with valid information' do
    fill_in 'Email', with: "email-#{rand(1000)}@fake.com"
    fill_in 'Name', with: "Tester Mcgee"
    fill_in 'Password', with: 'password'
    fill_in 'Password confirmation', with: 'password'
    click_button 'Sign up'
    expect(page).to have_content 'signed up successfully'
  end

  scenario 'signing up with invalid information' do
    click_button 'Sign up'
    expect(page).to have_content 'error'
  end
end
