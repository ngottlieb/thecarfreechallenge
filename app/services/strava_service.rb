# currently we use the strava-api-v3 gem, so this abstraction is little redundant,
# but it's not well-maintained so we may need to expand this
module StravaService
  extend self

  def activities(user, access_token, opts={})
    client = Strava::Api::V3::Client.new(:access_token => access_token)
    activities = client.list_athlete_activities(opts)
  end
end
