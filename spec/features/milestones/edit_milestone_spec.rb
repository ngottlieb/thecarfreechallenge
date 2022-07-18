feature 'Edit a milestone' do
  given!(:milestone) { FactoryBot.create :milestone }

  background do
    login_as(user, scope: :user)
    visit milestones_path
  end

  context 'as a non-admin' do
    given(:user) { FactoryBot.create :user, admin: false }

    scenario 'button should not be visible' do
      expect(page).to_not have_link "Edit"
    end
  end

  context 'as an admin' do
    given(:user) { FactoryBot.create :user, admin: true, measurement_system: :imperial_system }
    background do
      find(".milestone-#{milestone.id}").find_link('Edit').click
    end

    scenario 'editing a milestone' do
      fill_in 'milestone[threshold]', with: '12345'
      click_button 'Submit'
      expect(all("tr.milestone-#{milestone.id} td")[2]).to have_content('12345')
    end

    scenario 'uploading a badge' do
      attach_file "Badge", "#{Rails.root}/spec/support/test-fish.jpg"
      click_button "Submit"
      expect(page).to have_selector "tr.milestone-#{milestone.id} td img"
    end
  end
end
