require 'test_helper'

class AdsRotationTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user,name: "Provider" , email: "#{name}@bilbo.mx".downcase, roles: "provider")
    @project = @user.projects.first
    @board = create(:board, project: @project, name: "Board", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "50000", face: "north", start_time: Time.zone.parse("8:00"), end_time: Time.zone.parse("02:00"))
    @ad_10 = create(:ad, name: "10 secs", project: @project, duration: 10)
    @ad_20 = create(:ad, name: "20 secs", project: @project, duration: 20)
    @ad_30 = create(:ad, name: "30 secs", project: @project, duration: 30)
  end

  ########################################### Start Cases that must pass ###################################
  test "Budget campaigns low occupation" do
    #~25% use
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, budget: 100)
    campaign_2 = create(:campaign, name: "2 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_20.id, state: true, status: 0, budget: 200)
    campaign_3 = create(:campaign, name: "3 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_30.id, state: true, status: 0, budget: 300)
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Budget campaigns moderated occupation" do
    #~50% use
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, budget: 200)
    campaign_2 = create(:campaign, name: "2 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_20.id, state: true, status: 0, budget: 400)
    campaign_3 = create(:campaign, name: "3 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_30.id, state: true, status: 0, budget: 600)
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Budget campaigns high occupation" do
    #~95% use
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, budget: 400)
    campaign_2 = create(:campaign, name: "2 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_20.id, state: true, status: 0, budget: 700)
    campaign_3 = create(:campaign, name: "3 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_30.id, state: true, status: 0, budget: 1200)
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Campaigns per minute low occupation" do
    #25% use
    campaign_1 = create(:campaign, name: "1 Minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, imp: 1, minutes: 2)
    campaign_2 = create(:campaign, name: "2 Minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_20.id, state: true, status: 0, imp: 1, minutes: 4)
    campaign_3 = create(:campaign, name: "3 Minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_30.id, state: true, status: 0, imp: 1, minutes: 6)
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Campaigns per minute moderated occupation" do
    #50% use
    campaign_1 = create(:campaign, name: "1 Minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, imp: 2, minutes: 2)
    campaign_2 = create(:campaign, name: "2 Minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_20.id, state: true, status: 0, imp: 2, minutes: 4)
    campaign_3 = create(:campaign, name: "3 Minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_30.id, state: true, status: 0, imp: 2, minutes: 6)
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Campaigns per minute high occupation" do
    #100% use
    campaign_1 = create(:campaign, name: "1 Minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, imp: 3, minutes: 1)
    campaign_3 = create(:campaign, name: "3 Minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_30.id, state: true, status: 0, imp: 1, minutes: 1)
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Campaigns per hour low occupation" do
    #~25% use
    campaign_1 = create(:campaign, name: "1 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_20.id, state: true, status: 0)
    campaign_3 = create(:campaign, name: "3 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_30.id, state: true, status: 0)
    campaign_1.impression_hours.create(start: "2000-01-01 08:00:00", end: "2000-01-01 10:00:00", imp: 350, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 10:00:00", end: "2000-01-01 11:00:00", imp: 100, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 11:00:00", end: "2000-01-01 14:00:00", imp: 360, day: "everyday")
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Campaigns per hour moderated occupation" do
    #~50% use
    campaign_1 = create(:campaign, name: "1 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_20.id, state: true, status: 0)
    campaign_3 = create(:campaign, name: "3 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0)
    campaign_1.impression_hours.create(start: "2000-01-01 08:00:00", end: "2000-01-01 11:00:00", imp: 450, day: "everyday")
    campaign_1.impression_hours.create(start: "2000-01-01 11:00:00", end: "2000-01-01 14:00:00", imp: 330, day: "everyday")
    campaign_1.impression_hours.create(start: "2000-01-01 14:00:00", end: "2000-01-01 17:00:00", imp: 300, day: "everyday")

    campaign_2.impression_hours.create(start: "2000-01-01 08:00:00", end: "2000-01-01 11:00:00", imp: 165, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 11:00:00", end: "2000-01-01 14:00:00", imp: 150, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 14:00:00", end: "2000-01-01 17:00:00", imp: 225, day: "everyday")

    campaign_3.impression_hours.create(start: "2000-01-01 08:00:00", end: "2000-01-01 11:00:00", imp: 300, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 11:00:00", end: "2000-01-01 14:00:00", imp: 450, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 14:00:00", end: "2000-01-01 17:00:00", imp: 330, day: "everyday")
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Campaigns per hour high occupation" do
    #100% use
    campaign_1 = create(:campaign, name: "1 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_20.id, state: true, status: 0)
    campaign_3 = create(:campaign, name: "3 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0)
    campaign_1.impression_hours.create(start: "2000-01-01 08:00:00", end: "2000-01-01 11:00:00", imp: 450, day: "everyday")
    campaign_1.impression_hours.create(start: "2000-01-01 11:00:00", end: "2000-01-01 14:00:00", imp: 330, day: "everyday")
    campaign_1.impression_hours.create(start: "2000-01-01 14:00:00", end: "2000-01-01 17:00:00", imp: 300, day: "everyday")
    campaign_1.impression_hours.create(start: "2000-01-01 17:00:00", end: "2000-01-01 02:00:00", imp: 1000, day: "everyday")

    campaign_2.impression_hours.create(start: "2000-01-01 08:00:00", end: "2000-01-01 11:00:00", imp: 165, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 11:00:00", end: "2000-01-01 14:00:00", imp: 150, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 14:00:00", end: "2000-01-01 17:00:00", imp: 225, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 17:00:00", end: "2000-01-01 02:00:00", imp: 620, day: "everyday")

    campaign_3.impression_hours.create(start: "2000-01-01 08:00:00", end: "2000-01-01 11:00:00", imp: 300, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 11:00:00", end: "2000-01-01 14:00:00", imp: 450, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 14:00:00", end: "2000-01-01 17:00:00", imp: 330, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 17:00:00", end: "2000-01-01 02:00:00", imp: 1000, day: "everyday")

    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  #Test compatibility with multiple types of campaigns
  test "Multiple types low occupation" do
    #~25% use
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, budget: 250)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_20.id, state: true, status: 0)
    campaign_2.impression_hours.create(start: "2000-01-01 14:00:00", end: "2000-01-01 16:00:00", imp: 250, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 20:00:00", imp: 250, day: "everyday")
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Multiple types moderated occupation" do
    #~50% use
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, budget: 250)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_20.id, state: true, status: 0)
    campaign_3 = create(:campaign, name: "3 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_30.id, state: true, status: 0)
    campaign_4 = create(:campaign, name: "4 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, budget: 300)
    campaign_2.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 20:00:00", imp: 300, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 14:00:00", end: "2000-01-01 16:00:00", imp: 275, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 16:00:00", end: "2000-01-01 18:00:00", imp: 100, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 12:00:00", end: "2000-01-01 14:00:00", imp: 100, day: "everyday")

    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    campaign_4.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Multiple types high occupation" do
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, budget: 350)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0)
    campaign_3 = create(:campaign, name: "3 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0)
    campaign_4 = create(:campaign, name: "4 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, budget: 400)
    campaign_5 = create(:campaign, name: "5 Per minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, imp: 1, minutes: 1)
    campaign_6 = create(:campaign, name: "6 Per minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, imp: 2, minutes: 1)
    campaign_2.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 20:00:00", imp: 360, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 14:00:00", end: "2000-01-01 16:00:00", imp: 360, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 16:00:00", end: "2000-01-01 18:00:00", imp: 150, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 12:00:00", end: "2000-01-01 14:00:00", imp: 150, day: "everyday")

    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    campaign_4.board_campaigns.first.update(status: "approved")
    campaign_5.board_campaigns.first.update(status: "approved")
    campaign_6.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  # test "Multiple types high occupation" do
  #   campaign_1 = create(:campaign, name: "1 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, budget: 350)
  #   campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_20.id, state: true, status: 0)
  #   campaign_3 = create(:campaign, name: "3 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_30.id, state: true, status: 0)
  #   campaign_4 = create(:campaign, name: "4 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, budget: 400)
  #   campaign_5 = create(:campaign, name: "5 Per minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, imp: 1, minutes: 1)
  #   campaign_6 = create(:campaign, name: "6 Per minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, imp: 2, minutes: 1)
  #   campaign_2.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 20:00:00", imp: 180, day: "everyday")
  #   campaign_2.impression_hours.create(start: "2000-01-01 14:00:00", end: "2000-01-01 16:00:00", imp: 180, day: "everyday")
  #   campaign_3.impression_hours.create(start: "2000-01-01 16:00:00", end: "2000-01-01 18:00:00", imp: 50, day: "everyday")
  #   campaign_3.impression_hours.create(start: "2000-01-01 12:00:00", end: "2000-01-01 14:00:00", imp: 50, day: "everyday")
  #
  #   campaign_1.board_campaigns.first.update(status: "approved")
  #   campaign_2.board_campaigns.first.update(status: "approved")
  #   campaign_3.board_campaigns.first.update(status: "approved")
  #   campaign_4.board_campaigns.first.update(status: "approved")
  #   campaign_5.board_campaigns.first.update(status: "approved")
  #   campaign_6.board_campaigns.first.update(status: "approved")
  #   err = @board.update_ads_rotation(force_generate = true)
  #   ads = JSON.parse(@board.ads_rotation)
  #   occupation = 1-ads.count('-').to_f/ads.length
  #   assert err.empty? && occupation > 0
  # end

  ########################################### Start Cases that must fail ###################################
  # test "Impressions exceed board capacity" do
  #   campaign_1 = create(:campaign, name: "1 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, budget: 5000)
  #   err = test_ad_rotation(campaign_1, nil)
  #   assert err.include? I18n.t("bilbos.ads_rotation_error.max_budget_impressions", name: @board.name)
  # end

  test "Hour campaigns do not fit" do
    campaign_1 = create(:campaign, name: "1 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0)
    campaign_1.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 19:00:00", imp: 200, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 19:00:00", imp: 180, day: "everyday")
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    # p err if err.present?
    assert err.include? I18n.t("bilbos.ads_rotation_error.hour_campaign_space", campaign_name: campaign_2.name, bilbo_name: @board.name)
  end

  test "Hours not inside board time" do
    campaign_1 = create(:campaign, name: "1 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0)
    campaign_1.impression_hours.create(start: "2000-01-01 05:00:00", end: "2000-01-01 07:00:00", imp: 200, day: "everyday")
    campaign_1.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    assert err.include? I18n.t("bilbos.ads_rotation_error.hour_campaign_time", name: @board.name)
  end

  test "No more space for minute campaigns" do
    campaign_1 = create(:campaign, name: "1 Per Hour", project: @project, clasification: 2, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0)
    campaign_2 = create(:campaign, name: "2 Per Minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, imp: 3, minutes: 1)
    campaign_1.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 19:00:00", imp: 200, day: "everyday")
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    assert err.include? I18n.t("bilbos.ads_rotation_error.minute_campaign_space", campaign_name: campaign_2.name, bilbo_name: @board.name)
  end

  test "Budget campaigns do not fit" do
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, clasification: 0, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, budget: 800)
    campaign_2 = create(:campaign, name: "2 Per Minute", project: @project, clasification: 1, provider_campaign: true, ad_id: @ad_10.id, state: true, status: 0, imp: 5, minutes: 1)
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    assert err.include? I18n.t("bilbos.ads_rotation_error.budget_campaign_space", campaign_name: campaign_1.name, bilbo_name: @board.name)
  end

end
