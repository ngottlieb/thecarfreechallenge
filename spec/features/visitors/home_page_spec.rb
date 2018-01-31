include ActionView::Helpers::NumberHelper

# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
feature 'Home page' do

  # Scenario: Visit the home page
  #   Given I am a visitor
  #   When I visit the home page
  #   Then I see "Welcome"
  scenario 'visit the home page' do
    visit root_path
    expect(page).to have_content '#carfreechallenge'
  end

  it 'should have a user count' do
    visit root_path
    expect(page).to have_content "#{User.count}"
  end

  context "with some existing goals and activities" do
    given(:user) { FactoryBot.create :user }
    given!(:goal_1) { FactoryBot.create :goal, metric: :distance, user: user }
    given!(:goal_2) { FactoryBot.create :goal, metric: :vertical_gain, user: user }
    given!(:activity) { FactoryBot.create :activity, user: user, distance: 300, vertical_gain: 1000 }

    it 'should display vertical gain progress' do
      visit root_path
      expect(page).to have_content "#{number_with_delimiter(Activity.sum(:vertical_gain).to_i)} / #{number_with_delimiter(Goal.where(metric: :vertical_gain).sum(:total).to_i)}"
    end

    it 'should display distance progress' do
      visit root_path
      expect(page).to have_content "#{number_with_delimiter(Activity.sum(:distance).to_i)} / #{number_with_delimiter(Goal.where(metric: :distance).sum(:total).to_i)}"
    end
  end

end
