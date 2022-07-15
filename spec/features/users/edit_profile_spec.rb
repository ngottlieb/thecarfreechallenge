feature 'Edit profile' do
  given(:user) { FactoryBot.create :user }
  background do
    login_as(user, scope: :user)
    visit root_path
    click_link "Account"
  end

  scenario 'Changing name' do
    new_name = "Sandoz"
    fill_in "Name", with: new_name
    click_button "Update"
    expect(page).to have_content "Account updated"
    expect(find("input[name='user[name]']").value).to eq new_name
  end

  scenario 'Changing email' do
    new_email = "sandoz@sandoz.tz"
    fill_in "Email", with: new_email
    click_button "Update"
    expect(page).to have_content "Account updated"
    expect(find("input[name='user[email]']").value).to eq new_email
  end

  scenario 'Uploading an avatar' do
    attach_file "Avatar", "#{Rails.root}/spec/support/test-fish.jpg"
    click_button "Update"
    expect(page).to have_content "Account updated"
    expect(page).to have_selector(".user-avatar img")
  end
end