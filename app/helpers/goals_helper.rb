module GoalsHelper
  def progress_bar(goal)
    width = goal.percent_complete
    content_tag :div, class: 'progress-bar', style: "width: #{width}%;" do
      if width > 5
        goal.progress.round.to_s
      end
    end
  end
end
