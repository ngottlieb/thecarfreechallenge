namespace :backpopulate do
  desc "set existing goals start and end date to reflect the default 2018 dates"
  task :goal_dates => :environment do
    puts 'updating old goals to use 2018 start and end dates'
    Goal.where(start_date: nil, end_date: nil).update_all(
      start_date: Date.parse("Jan 1 2018"),
      end_date: Date.parse("Dec 31 2018")
    )
  end
end
