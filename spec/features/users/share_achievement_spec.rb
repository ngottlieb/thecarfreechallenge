feature 'Share achievement' do
  context 'as an anonymous user' do
    given(:user) { FactoryBot.create :user }

    scenario 'visit an achievement share page' do
      visit share_achievement_path(id: user.id, achievement: "member")
      expect(page).to have_content "#{user.name} has signed up"
    end
  end

  context 'as a logged in user' do
    given(:user) { FactoryBot.create :user }

    background do
      login_as(user, scope: :user)
      visit dashboard_path
      find('.achievement').click_link 'Share'
    end

    it 'should display the share link' do
      expect(page).to have_css(".fb-share-button")
    end
  end
end
