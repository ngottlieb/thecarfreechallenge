# currently we use the strava-api-v3 gem, so this abstraction is little redundant,
# but it's not well-maintained so we may need to expand this
module StravaService
  extend self

  def activities(user, opts={})
    oauth_client = Strava::OAuth::Client.new(
      client_id: ENV["STRAVA_APP_ID"],
      client_secret: ENV["STRAVA_CLIENT_SECRET"]
    )

    # refresh token if needed (Strava returns existing token if it's not expired)
    response = oauth_client.oauth_token(
      refresh_token: user.strava_refresh_token,
      grant_type: 'refresh_token'
    )

    user.update(
      strava_refresh_token: response.refresh_token,
      strava_access_token: response.access_token
    )

    api_client = Strava::Api::Client.new(
      access_token: response.access_token
    )

    activities = api_client.athlete_activities(opts)
  end
end
