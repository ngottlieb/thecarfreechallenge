feature 'Delete a milestone' do
  given!(:milestone) { FactoryBot.create :milestone }

  background do
    login_as(user, scope: :user)
    visit milestones_path
  end

  context 'as a non-admin' do
    given(:user) { FactoryBot.create :user, admin: false }

    scenario 'button should not be visible' do
      expect(page).to_not have_link "Delete"
    end
  end

  context 'as an admin' do
    given(:user) { FactoryBot.create :user, admin: true }

    scenario 'clicking delete on a milestone' do
      find(".milestone-#{milestone.id}").find_link('Delete').click
      expect(page).to_not have_css(".milestone-#{milestone.id}")
    end
  end
end
