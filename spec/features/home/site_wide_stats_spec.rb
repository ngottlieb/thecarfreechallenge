include ActionView::Helpers::NumberHelper
feature 'Dashboard page' do

  context 'as a logged in user' do
    given(:user) { FactoryBot.create :user }
    background { login_as(user, scope: :user) }

    context 'without goals or activities' do
      feature 'visit the site wide stats page' do

        it 'should load the page' do
          visit site_wide_stats_path
          expect(page).to have_content "Who's Doing It"
        end
      end
    end

    context 'with some goals and activities' do
      given!(:activity) { FactoryBot.create :activity, distance: 100, vertical_gain: 200 }
      given!(:goal_v1) { FactoryBot.create :goal, metric: :vertical_gain, total: 10000 }
      given!(:goal_d1) { FactoryBot.create :goal, metric: :distance, total: 10000 }
      given!(:goal_d2) { FactoryBot.create :goal, metric: :distance, total: 5000 }

      feature 'visit the site wide stats page' do
        background { visit site_wide_stats_path }

        it 'should show the total goals for distance' do
          expect(page).to have_content number_with_delimiter((goal_d1.total + goal_d2.total).to_i)
        end

        it 'should show the total goals for vertical gain' do
          expect(page).to have_content number_with_delimiter(goal_v1.total.to_i)
        end

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
            expect(page).to have_content 'Kilometers'
          end

          it 'should show metric vertical gain label' do
            expect(page).to have_content 'Meters'
          end

          it 'should show metric conversion of goal distance sum' do
            expect(page).to have_content number_with_delimiter(Goal.miles_to_kms(goal_d1.total + goal_d2.total).to_i)
          end
        end
      end
    end
  end
end
