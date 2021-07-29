require 'test_helper'

class AdsRotationTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user,name: "Provider" , email: "#{name}@bilbo.mx".downcase, roles: "provider")
    @project = @user.projects.first
    @board = create(:board, project: @project, name: "Board", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "75000", provider_earnings: "60000", face: "north", start_time: Time.zone.parse("8:00"), end_time: Time.zone.parse("02:00"), steps: false)
    # @ad_10 = create(:ad, name: "10 secs", project: @project, duration: 10)
    # @ad_20 = create(:ad, name: "20 secs", project: @project, duration: 20)
    # @ad_30 = create(:ad, name: "30 secs", project: @project, duration: 30)
  end

  ########################################### Start Cases that must pass ###################################
  test "Budget campaigns low occupation" do
    #~25% use
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 10, state: true, status: 0, budget_distribution: {"#{@board.id}": "100"}.to_json)
    campaign_2 = create(:campaign, name: "2 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 20, state: true, status: 0, budget_distribution: {"#{@board.id}": "200"}.to_json)
    campaign_3 = create(:campaign, name: "3 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 30, state: true, status: 0, budget_distribution: {"#{@board.id}": "300"}.to_json)
    campaign_1.board_campaigns.first.update(status: "approved", budget: 100)
    campaign_2.board_campaigns.first.update(status: "approved", budget: 200)
    campaign_3.board_campaigns.first.update(status: "approved", budget: 300)
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Budget campaigns moderated occupation" do
    #~50% use
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 10, state: true, status: 0, budget_distribution: {"#{@board.id}": "200"}.to_json)
    campaign_2 = create(:campaign, name: "2 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 20, state: true, status: 0, budget_distribution: {"#{@board.id}": "400"}.to_json)
    campaign_3 = create(:campaign, name: "3 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 30, state: true, status: 0, budget_distribution: {"#{@board.id}": "600"}.to_json)
    campaign_1.board_campaigns.first.update(status: "approved", budget: 200)
    campaign_2.board_campaigns.first.update(status: "approved", budget: 400)
    campaign_3.board_campaigns.first.update(status: "approved", budget: 600)
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Budget campaigns high occupation" do
    #~95% use
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 10, state: true, status: 0, budget_distribution: {"#{@board.id}": "400"}.to_json)
    campaign_2 = create(:campaign, name: "2 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 20, state: true, status: 0, budget_distribution: {"#{@board.id}": "700"}.to_json)
    campaign_3 = create(:campaign, name: "3 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 30, state: true, status: 0, budget_distribution: {"#{@board.id}": "1200"}.to_json)
    campaign_1.board_campaigns.first.update(status: "approved", budget: 400)
    campaign_2.board_campaigns.first.update(status: "approved", budget: 700)
    campaign_3.board_campaigns.first.update(status: "approved", budget: 1200)
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Campaigns per minute low occupation" do
    #25% use
    campaign_1 = create(:campaign, name: "1 Minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 10, state: true, status: 0, imp: 1, minutes: 2)
    campaign_2 = create(:campaign, name: "2 Minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 20, state: true, status: 0, imp: 1, minutes: 4)
    campaign_3 = create(:campaign, name: "3 Minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 30, state: true, status: 0, imp: 1, minutes: 6)
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
    campaign_1 = create(:campaign, name: "1 Minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 10, state: true, status: 0, imp: 2, minutes: 2)
    campaign_2 = create(:campaign, name: "2 Minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 20, state: true, status: 0, imp: 2, minutes: 4)
    campaign_3 = create(:campaign, name: "3 Minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 30, state: true, status: 0, imp: 2, minutes: 6)
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
    campaign_1 = create(:campaign, name: "1 Minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 10, state: true, status: 0, imp: 3, minutes: 1)
    campaign_3 = create(:campaign, name: "3 Minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 30, state: true, status: 0, imp: 1, minutes: 1)
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Campaigns per hour low occupation" do
    #~25% use
    campaign_1 = create(:campaign, name: "1 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 10, state: true, status: 0)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 20, state: true, status: 0)
    campaign_3 = create(:campaign, name: "3 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 30, state: true, status: 0)
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
    campaign_1 = create(:campaign, name: "1 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 10, state: true, status: 0)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 20, state: true, status: 0)
    campaign_3 = create(:campaign, name: "3 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 10, state: true, status: 0)
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
    campaign_1 = create(:campaign, name: "1 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 10, state: true, status: 0)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 20, state: true, status: 0)
    campaign_3 = create(:campaign, name: "3 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 10, state: true, status: 0)
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
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 10, state: true, status: 0, budget_distribution: {"#{@board.id}": "250"}.to_json)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 20, state: true, status: 0)
    campaign_2.impression_hours.create(start: "2000-01-01 14:00:00", end: "2000-01-01 16:00:00", imp: 250, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 20:00:00", imp: 250, day: "everyday")
    campaign_1.board_campaigns.first.update(status: "approved", budget: 250)
    campaign_2.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Multiple types moderated occupation" do
    #~50% use
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 10, state: true, status: 0, budget_distribution: {"#{@board.id}": "250"}.to_json)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 20, state: true, status: 0)
    campaign_3 = create(:campaign, name: "3 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 30, state: true, status: 0)
    campaign_4 = create(:campaign, name: "4 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 10, state: true, status: 0, budget_distribution: {"#{@board.id}": "300"}.to_json)
    campaign_2.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 20:00:00", imp: 300, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 14:00:00", end: "2000-01-01 16:00:00", imp: 275, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 16:00:00", end: "2000-01-01 18:00:00", imp: 100, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 12:00:00", end: "2000-01-01 14:00:00", imp: 100, day: "everyday")

    campaign_1.board_campaigns.first.update(status: "approved", budget: 250)
    campaign_2.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    campaign_4.board_campaigns.first.update(status: "approved", budget: 300)
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  test "Multiple types high occupation" do
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 10, state: true, status: 0, budget_distribution: {"#{@board.id}": "350"}.to_json)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 10, state: true, status: 0)
    campaign_3 = create(:campaign, name: "3 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 10, state: true, status: 0)
    campaign_4 = create(:campaign, name: "4 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 10, state: true, status: 0, budget_distribution: {"#{@board.id}": "400"}.to_json)
    campaign_5 = create(:campaign, name: "5 Per minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 10, state: true, status: 0, imp: 1, minutes: 1)
    campaign_6 = create(:campaign, name: "6 Per minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 10, state: true, status: 0, imp: 2, minutes: 1)
    campaign_2.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 20:00:00", imp: 360, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 14:00:00", end: "2000-01-01 16:00:00", imp: 360, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 16:00:00", end: "2000-01-01 18:00:00", imp: 150, day: "everyday")
    campaign_3.impression_hours.create(start: "2000-01-01 12:00:00", end: "2000-01-01 14:00:00", imp: 150, day: "everyday")

    campaign_1.board_campaigns.first.update(status: "approved", budget: 350)
    campaign_2.board_campaigns.first.update(status: "approved")
    campaign_3.board_campaigns.first.update(status: "approved")
    campaign_4.board_campaigns.first.update(status: "approved", budget: 400)
    campaign_5.board_campaigns.first.update(status: "approved")
    campaign_6.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    ads = JSON.parse(@board.ads_rotation)
    occupation = 1-ads.count('-').to_f/ads.length
    assert err.empty? && occupation > 0
  end

  # test "Multiple types high occupation" do
  #   campaign_1 = create(:campaign, name: "1 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 10, state: true, status: 0, budget: 350)
  #   campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 20, state: true, status: 0)
  #   campaign_3 = create(:campaign, name: "3 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 30, state: true, status: 0)
  #   campaign_4 = create(:campaign, name: "4 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 10, state: true, status: 0, budget: 400)
  #   campaign_5 = create(:campaign, name: "5 Per minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 10, state: true, status: 0, imp: 1, minutes: 1)
  #   campaign_6 = create(:campaign, name: "6 Per minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 10, state: true, status: 0, imp: 2, minutes: 1)
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
  #   debugger
  #   assert err.empty? && occupation > 0
  # end

  ########################################### End Cases That must pass #####################################
  ########################################### Start Cases that must fail ###################################
  # test "Impressions exceed board capacity" do
  #   campaign_1 = create(:campaign, name: "1 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 10, state: true, status: 0, budget: 5000)
  #   err = test_ad_rotation(campaign_1, nil)
  #   assert err.include? I18n.t("bilbos.ads_rotation_error.max_budget_impressions", name: @board.name)
  # end

  test "Hour campaigns do not fit" do
    campaign_1 = create(:campaign, name: "1 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 10, state: true, status: 0)
    campaign_2 = create(:campaign, name: "2 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 10, state: true, status: 0)
    campaign_1.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 19:00:00", imp: 200, day: "everyday")
    campaign_2.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 19:00:00", imp: 180, day: "everyday")
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    # p err if err.present?
    assert err.include? I18n.t("bilbos.ads_rotation_error.hour_campaign_space", campaign_name: campaign_2.name, bilbo_name: @board.name)
  end

  test "Hours not inside board time" do
    campaign_1 = create(:campaign, name: "1 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 10, state: true, status: 0)
    campaign_1.impression_hours.create(start: "2000-01-01 05:00:00", end: "2000-01-01 07:00:00", imp: 200, day: "everyday")
    campaign_1.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    assert err.include? I18n.t("bilbos.ads_rotation_error.hour_campaign_time", name: @board.name)
  end

  test "No more space for minute campaigns" do
    campaign_1 = create(:campaign, name: "1 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 10, state: true, status: 0)
    campaign_2 = create(:campaign, name: "2 Per Minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 10, state: true, status: 0, imp: 3, minutes: 1)
    campaign_1.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 19:00:00", imp: 200, day: "everyday")
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_2.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    assert err.include? I18n.t("bilbos.ads_rotation_error.minute_campaign_space", campaign_name: campaign_2.name, bilbo_name: @board.name)
  end

  test "Budget campaigns do not fit" do
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 10, state: true, status: 0, budget_distribution: {"#{@board.id}": "800"}.to_json)
    campaign_2 = create(:campaign, name: "2 Per Minute", project: @project, boards: [@board], classification: 1, provider_campaign: true, duration: 10, state: true, status: 0, imp: 5, minutes: 1)
    campaign_1.board_campaigns.first.update(status: "approved", budget: 800)
    campaign_2.board_campaigns.first.update(status: "approved")
    err = @board.update_ads_rotation(force_generate = true)
    assert err.include? I18n.t("bilbos.ads_rotation_error.budget_campaign_space", campaign_name: campaign_1.name, bilbo_name: @board.name)
  end

  ########################################### End Cases that must fail #####################################
  ########################################### Start Remaining impressions test #############################
  test "First day test" do
    #Create a random number of impressions, and verify that that the remaining impressions plus the created impressions match the maximum ammount of imprressions per day
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 20, state: true, status: 0, budget_distribution: {"#{@board.id}": "700"}.to_json)
    campaign_1.board_campaigns.first.update(status: "approved", budget: 700)
    err = @board.update_ads_rotation(force_generate = true)
    start_time = Time.parse(@board.start_time.strftime("%H:%M")) - @board.utc_offset.minutes
    end_time = Time.parse(@board.end_time.strftime("%H:%M")) - @board.utc_offset.minutes
    current_time = Time.now.utc + 15.seconds
    end_time += 1.day if start_time >= end_time and current_time >= end_time
    start_time -= 1.day if start_time >= end_time and current_time < end_time
    count = 0
    [campaign_1.board_campaigns.first.remaining_impressions, Faker::Number.between(from: 10, to: 500)].min.times do
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: campaign_1.id, board_id: @board.id, created_at: rand_time(start_time, end_time), api_token: @board.api_token, duration: campaign_1.duration)
      count += 1
    end
    campaign_1.board_campaigns.update(update_remaining_impressions: true)
    assert_equal JSON.parse(@board.ads_rotation).count(campaign_1.id), campaign_1.remaining_impressions(@board) + count
    assert_equal (campaign_1.budget_per_bilbo(@board)/(@board.get_cycle_price(campaign_1) * campaign_1.duration/@board.duration)).to_i, campaign_1.remaining_impressions(@board) + count
  end

  test "Second Day test budget" do
    start_time = Time.parse(@board.start_time.strftime("%H:%M")) - @board.utc_offset.minutes
    end_time = Time.parse(@board.end_time.strftime("%H:%M")) - @board.utc_offset.minutes
    campaign_1 = create(:campaign, name: "1 Budget", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 20, state: true, status: 0, budget_distribution: {"#{@board.id}": "300"}.to_json)
    campaign_1.board_campaigns.first.update(status: "approved", budget: 300)
    campaign_1.board_campaigns.first.remaining_impressions.times do
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: campaign_1.id, board_id: @board.id, created_at: rand_time(start_time-1.day, end_time-1.day), api_token: @board.api_token, duration: campaign_1.duration)
    end
    board_campaign = BoardsCampaigns.where(campaign_id: campaign_1.id)
    board_campaign.update(update_remaining_impressions: true)
    assert_equal (campaign_1.budget_per_bilbo(@board)/(@board.get_cycle_price(campaign_1) * campaign_1.duration/@board.duration)).to_i, campaign_1.remaining_impressions(@board)
  end

  test "Second Day test per hour" do
    start_time = Time.parse(@board.start_time.strftime("%H:%M")) - @board.utc_offset.minutes
    end_time = Time.parse(@board.end_time.strftime("%H:%M")) - @board.utc_offset.minutes
    campaign_1 = create(:campaign, name: "1 Per Hour", project: @project, boards: [@board], classification: 2, provider_campaign: true, duration: 10, state: true, status: 0)
    campaign_1.impression_hours.create(start: "2000-01-01 18:00:00", end: "2000-01-01 19:00:00", imp: 200, day: "everyday")
    campaign_1.board_campaigns.first.update(status: "approved")
    campaign_1.board_campaigns.first.remaining_impressions.times do
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: campaign_1.id, board_id: @board.id, created_at: rand_time(start_time-1.day, end_time-1.day), api_token: @board.api_token, duration: campaign_1.duration)
    end
    campaign_1.board_campaigns.update(update_remaining_impressions: true)
    assert_equal campaign_1.impression_hours.pluck(:imp).sum, campaign_1.remaining_impressions(@board)
  end

  ########################################### End Remaining impressions test ###############################
end
