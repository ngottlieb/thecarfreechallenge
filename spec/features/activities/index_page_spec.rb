feature 'Activities index page' do
  context 'as an anonymous user' do
    background { visit activities_path }
    scenario 'visit the activities page' do
      # should be redirected to login
      expect(page).to have_content 'Login'
    end
  end

  context 'as a logged in user' do
    given(:user) { FactoryBot.create :user }
    given!(:activity) { FactoryBot.create :activity, user: user }
    background do
      login_as(user, scope: :user)
    end

    it 'should display the users\' activities' do
      visit activities_path
      expect(page).to have_css('tr', class: "activity-#{activity.id}")
    end

    context 'as a strava user' do
      background { allow(user).to receive(:is_strava_user?).and_return(true) }

      it 'should include the strava notice at the top' do
        visit activities_path
        expect(page).to have_content 'How to Use #carfreechallenge With Strava'
      end
    end

    ['imperial_system', 'metric_system'].each do |system|
      context "as a #{system} user" do
        given(:user) { FactoryBot.create :user, measurement_system: system }

        [Goal.metric_label('distance', system), Goal.metric_label('vertical_gain', system)].each do |unit|
          it "should have a column labeled #{unit}" do
            visit activities_path
            expect(page).to have_css('th', text: unit.titlecase)
          end
        end
      end
    end

  end
end
