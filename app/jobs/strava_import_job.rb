# given a user and an access token,
# retrieves and processes all Activities
class StravaImportJob < ApplicationJob
  queue_as :default

  before_enqueue :set_user_job_in_progress_flag
  after_perform :unset_user_job_in_progress_flag

  def perform(user)
    # TODO: modify these before and after dates to reflect user timezone
    per_page = Activity::PER_PAGE # max (identified through manual testing)
    page = 1
    activities = []

    after_query_date = user.start_of_earliest_goal.try(:to_i) || Activity::AFTER_EPOCH

    # loop through to ensure we retrieve all the activities
    loop do
      import_batch = StravaService.activities(user, { after: after_query_date,
                                          per_page: per_page, page: page})
      activities += import_batch
      break if import_batch.count < per_page
      # increment page and run the import again
      page += 1
    end

    imported_activities = []
    activities.each do |act|
      begin
        imported_activities << Activity.update_or_create_from_strava(act) if Activity::STRAVA_HASHTAG_MATCHERS.any?{ |tag| act.name.downcase.include? tag }
      rescue Exception => msg
        logger.error "There was an error importing Strava activity #{act.id}: #{msg}; skipping"
      end
    end
    logger.info "Successfully imported #{imported_activities.count} activities"
    logger.info "Scanned but did not import #{activities.count - imported_activities.count}"
  end

  private

  def set_user_job_in_progress_flag
    self.arguments[0].update import_in_progress: true
  end

  def unset_user_job_in_progress_flag
    self.arguments[0].update import_in_progress: false
  end

end
