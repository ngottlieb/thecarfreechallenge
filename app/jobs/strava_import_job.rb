# given a user and an access token,
# retrieves and processes all Activities
# from 2018
class StravaImportJob < ApplicationJob
  queue_as :default

  around_perform :set_user_job_in_progress_flag

  def perform(user, access_token)
    # TODO: modify these before and after dates to reflect user timezone
    activities = StravaService.activities(user, access_token, { after: Activity::AFTER_EPOCH,
                                          before: Activity::BEFORE_EPOCH })
    imported_activities = []
    activities.each do |act|
      begin
        imported_activities << Activity.update_or_create_from_strava(act) if act[:name].include? "#carfreechallenge"
      rescue Exception => msg
        logger.error "There was an error importing Strava activity #{act[:id]}: #{msg}; skipping"
      end
    end
    logger.info "Successfully imported #{imported_activities.count} activities"
    logger.info "Failed to import #{activities.count - imported_activities.count}"
  end

  private
  def set_user_job_in_progress_flag
    self.arguments[0].update import_in_progress: true
    yield
    self.arguments[0].update import_in_progress: false
  end

end
