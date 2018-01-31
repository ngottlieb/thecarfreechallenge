feature 'Dashboard page' do

  context 'as a logged in user' do
    given(:user) { FactoryBot.create :user }
    background { login_as(user, scope: :user) }

    context 'without goals or activities' do
      feature 'visit the dashboard' do
        background { visit root_path }

        it 'should have + Set a Goal link' do
          expect(page).to have_link "+ Set a Goal"
        end

        it 'should have Getting Started copy' do
          expect(page).to have_content 'Getting Started'
        end
      end

    end

    context 'with existing goals' do
      given!(:goal) { FactoryBot.create :goal, user: user }

      feature 'visit the dashboard' do
        background { visit root_path }

        it 'should display the goal' do
          expect(page).to have_content "#{goal.converted_total} car-free #{goal.metric_label}"
        end

        it 'should display the goal sharing button' do
          expect(page).to have_link 'Share'
        end
      end
    end

    context 'with existing activities' do
      given!(:activities) { FactoryBot.create_list(:activity, 3, user: user) }

      feature 'visit the dashboard' do

        it 'should display the activity count' do
          visit root_path
          expect(page).to have_content "#{activities.count}"
        end
      end
    end
  end
end
