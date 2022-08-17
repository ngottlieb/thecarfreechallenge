module StravaTesting
  extend self
  require 'rspec/mocks'
  extend RSpec::Mocks::ExampleMethods
  RSpec::Mocks.setup
  
  def example_activity(name: 'Test #carfreechallenge activity', activity_id: rand(1000000), user_id: rand(100000), start_date: Time.parse("2018-05-21T13:35:33Z"))
    double("activity",
      id: activity_id,
      resource_state: 2,
      external_id: "garmin_push_#{rand(100000000)}",
      upload_id: rand(1000000000),
      athlete: double("user", id: user_id, resource_state: 1),
      name: name,
      distance: rand(100000),
      moving_time: rand(10000),
      elapsed_time: rand(10000),
      total_elevation_gain: rand(1000),
      type: "Ride",
      start_date: start_date,
      start_date_local: "2017-05-21T06:35:33Z",
      timezone: "(GMT-08:00) America/Los_Angeles",
      utc_offset: -25200,
      start_latlng: [
        38.46,
        -123.05
      ],
      end_latlng: [
        37.87,
        -122.5
      ],
      location_city: nil,
      location_state: nil,
      location_country: "United States",
      start_latitude: 38.46,
      start_longitude: -123.05,
      achievement_count: 22,
      kudos_count: 35,
      comment_count: 0,
      athlete_count: 3,
      photo_count: 0,
      map: {
        "id": "a999582172",
        "summary_polyline": '}_wiFh{_nVxJaDiBmKbc@`RpEda@pb@~b@v_@xiAcF|l@gb@j`ABrg@~KfNxh@zLrPpSr`@yTvDjr@f`B_q@`@wMlJnC|h@sU`^wBdHaMx]d@lHuLcCcLxLq@nKoUlnA_]hDyIhi@mVf@wH|tAgd@zi@qn@vQee@rZoPvJgVjQtGrIsNnDxS~UsKpqAecBmFwn@bAun@wb@e\\wMiWcFcp@sOmUcX}N}Lya@qBsn@bCg[lOeQjj@uwBzMwuCvc@yM~HwYgVsc@kA}a@jp@{kCJqcC`Okm@pCqz@v|@_hCnYqaBlQ_g@fe@y_@b{@kEzo@cPzfAsdBhAw~AuDeg@{J}l@gYku@wCgd@xK{kB|vAq|Chq@yiBrc@sp@bFaqC~Xam@{IcHhMsc@p_@bRvMeB~cBw`AtT_Vfu@hu@~}@nd@nCsvBrLi}@mB}J``@y{@~oBmuCxqAa[fpAgDhdBnSz_ArTpJbM|zAin@xR_VxQzKrS`^fIp@bNmExa@uf@fEi`B`^{}@na@q]ta@FndA`c@~c@^`Nj]?jMlsAtl@bLiN`v@m@vRkZvQhJzGkGu@kOxk@uKvYiiAtt@ki@zZyDtNlCG`Jz^fDny@orAfUkRhSl@nt@rf@rs@fH|EjP`~@RfFcWjMyIn]~LtJqL~QH`WdJXpaAta@hGd|AsPxwAasBdc@m\\eHK',
        "resource_state": 2
      },
      trainer: false,
      commute: false,
      manual: false,
      private: false,
      flagged: false,
      gear_id: "b3123396",
      average_speed: 6.513,
      max_speed: 17.3,
      average_temp: 26,
      average_watts: 132.1,
      kilojoules: 2476.6,
      device_watts: false,
      has_heartrate: false,
      elev_high: 79.6,
      elev_low: -9.6,
      pr_count: 4,
      total_photo_count: 0,
      has_kudoed: false,
      workout_type: 10,
      suffer_score: nil
    )
  end
end
