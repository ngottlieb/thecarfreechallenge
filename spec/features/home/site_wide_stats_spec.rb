include ActionView::Helpers::NumberHelper
feature 'Dashboard page' do

  context 'as a logged in user' do
    given(:user) { FactoryBot.create :user }
    background { login_as(user, scope: :user) }

    context 'without activities' do
      feature 'visit the site wide stats page' do

        it 'should load the page' do
          visit site_wide_stats_path
          expect(page).to have_content "Participants"
        end
      end
    end

    context 'with activities' do
      given!(:activity) { FactoryBot.create :activity, distance: 100, vertical_gain: 200 }

      feature 'visit the site wide stats page' do
        background { visit site_wide_stats_path }

        it 'should show the sum of activities distance' do
          expect(page).to have_content number_with_delimiter(activity.distance.to_i)
        end

        it 'should show the sum of activities vertical_gain' do
          expect(page).to have_content number_with_delimiter(activity.vertical_gain.to_i)
        end
      end

      context 'as a metric user' do
        given(:user) { FactoryBot.create :user, measurement_system: :metric_system }

        feature 'visit the site wide stats page' do
          background { visit site_wide_stats_path }

          it 'should show metric distance label' do
            expect(page).to have_content 'kilometers'
          end

          it 'should show metric vertical gain label' do
            expect(page).to have_content 'meters'
          end
        end
      end
    end
  end
end
