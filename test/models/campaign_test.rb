require 'test_helper'

class CampaignTest < ActiveSupport::TestCase
  i_suck_and_my_tests_are_order_dependent!
  include Rails.application.routes.url_helpers
  setup do
    @name = "Ussopn"
    @campaign_name = "Pirate hunter"
    @project =  create(:project, name: @name)
    @user = create(:user,role: "provider", name: @name)
    @board = create(:board,project: @user.projects.first, name: "Board", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @campaign = create(:campaign, boards: [@board], name: @campaign_name, project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json)
  end
  test "is provider" do
    assert @user.is_provider?
  end
  test "create budget campaign" do
    @campaign = create(:campaign, boards: [@board], name: "budget campaign", project: @user.projects.first, classification: 0, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "100"}.to_json)
    assert_equal "budget", @campaign.classification
  end
  test "create per minute campaign" do
    @campaign = create(:campaign, boards: [@board], name: "budget campaign", project: @user.projects.first, classification: 1, provider_campaign: @user.is_provider?)
    assert_equal "per_minute", @campaign.classification
  end
  test "create per hour campaign" do
    @campaign = create(:campaign, boards: [@board], name: "budget campaign", project: @user.projects.first, classification: 2, provider_campaign: @user.is_provider? )
    assert_equal "per_hour", @campaign.classification
  end
  test "has board" do
      assert 1, @campaign.boards.count
  end
  test "has content" do
    @content = create(:content, project: @project, url: "", multimedia_data: TestData.image_data)
    @board = create(:board,project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @boards_campaigns = create(:boards_campaigns, campaign_id: @campaign.id , board_id: @board.id, status: 1)
    @content_board_campaign = create(:contents_board_campaign, content_id: @content.id, boards_campaigns_id: @boards_campaigns.id)
    assert true, @campaign.board_campaigns.last.contents_board_campaign.present?
  end
  test "should run" do
    @board = create(:board,project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A
      ", base_earnings: "5000", face: "north")
      create(:boards_campaigns, board: @board, campaign: @campaign, budget: @board.minimum_budget)
      assert true, @campaign.should_run?(@board.id)
  end
  test "project status" do
    @campaign.project_status
    assert "Tu creativo no cuenta con imágenes para correr en los bilbos que no admiten video"
  end
  test "on going campaign" do
    @campaign =  create(:campaign, boards: [@board], name: "budget campaign", project: @user.projects.first, classification: 0, starts_at: "2020-10-10 05:00:00", ends_at: "2020-10-11 05:00:00", provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json)
    assert_equal false, @campaign.is_now_ongoing?
  end
  test "user has budget" do
    @user = create(:user, name: "Luffy", balance: "7777")
    @campaign = create(:campaign, boards: [@board], name: "budget campaign", project: @user.projects.first, classification: 0, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json)
    assert_equal true, @campaign.user_has_budget?
  end
  test "state off when campaign created" do
    @campaign = create(:campaign, boards: [@board], name: "TRUNKS", project: @user.projects.first, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json)
    assert true, @campaign.off
  end
  test "owner" do
    @user = create(:user, name: "Zoro")
    @campaign = create(:campaign, boards: [@board], name: "wano", project: @user.projects.first, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json)
    assert_equal @user, @campaign.owner
  end
  test "budget campaign has correct fields" do
    @budget = "100"
    @campaign = create(:campaign, boards: [@board], name: "budget campaign", project: @user.projects.first, classification: 0, budget: @budget, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "100"}.to_json)
      assert @budget, @campaign.budget
  end
  test "per minute campaign has correct fields" do
    @imp = 5
    @minutes = 5
    @campaign = create(:campaign, boards: [@board], name: "budget campaign", project: @user.projects.first, classification: 1, imp: @imp, minutes: @minutes, provider_campaign: @user.is_provider?)
      assert_equal @imp, @campaign.imp
      assert_equal @minutes, @campaign.minutes
  end
  test "per hour campaign has imp" do
    @campaign = create(:campaign, boards: [@board], name: "budget campaign", project: @user.projects.first, classification: 2, provider_campaign: @user.is_provider? )
    @imp = 5
    @impression_hour = create(:impression_hour, imp: @imp, campaign: @campaign)
    @campaign.reload
    assert @imp, @campaign.impression_hours.last
  end
  test "per hour campaign has start" do
    @campaign = create(:campaign, boards: [@board], name: "budget campaign", project: @user.projects.first, classification: 2, provider_campaign: @user.is_provider?)
    @start = "2000-01-01 13:00:00 -0600"
    @impression_hour = create(:impression_hour, start: @start, campaign: @campaign)
    @campaign.reload
    assert_equal @start, @campaign.impression_hours.last.start.to_s
  end
  test "per hour campaign has end" do
    @campaign = create(:campaign, boards: [@board], name: "budget campaign", project: @user.projects.first, classification: 2, provider_campaign: @user.is_provider?)
    @end = "2000-01-01 17:00:00 -0600"
    @impression_hour = create(:impression_hour, end: @end, campaign: @campaign)
    @campaign.reload
    assert_equal @end, @campaign.impression_hours.last.end.to_s
  end
  test "per hour campaign has day" do
    @campaign = create(:campaign, boards: [@board], name: "budget campaign", project: @user.projects.first, classification: 2, provider_campaign: @user.is_provider?)
    @day = "monday"
    @impression_hour = create(:impression_hour, day: @day, campaign: @campaign)
    @campaign.reload
    assert_equal @day, @campaign.impression_hours.last.day
  end
  test "cant update when is active"do
    @campaign = create(:campaign, boards: [@board], name: @campaign_name,project: @user.projects.first, project_id: @project.id, state: true, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json)
    assert "La campaña no puede editarse cuando está activa", @campaign.cant_update_when_active
  end
  test "build ad rotation" do
      assert_not nil, @campaign.check_build_ad_rotation
  end
  test "off method" do
    @camp1 = create(:campaign, boards: [@board], name: "off",project: @user.projects.first, project_id: @project.id, state: false, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json)
    assert true, @camp1.off
  end
  test "on method" do
    @camp2 = create(:campaign, boards: [@board], name: "on",project: @user.projects.first, project_id: @project.id, state: true, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json)
    assert true, @camp2.on
  end
  test "time to run true" do
    @campaign = create(:campaign, boards: [@board], name: @campaign_name, project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json, starts_at: Time.now.beginning_of_day, ends_at: 3.days.from_now.beginning_of_day)
    assert @campaign.time_to_run?(@board)
  end
  test "time to run false after end date" do
    @campaign = create(:campaign, boards: [@board], name: @campaign_name, project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json, starts_at: 3.days.ago.beginning_of_day, ends_at: 1.day.ago.beginning_of_day)
    assert_not @campaign.time_to_run?(@board)
  end
  test "time to run false days before start date" do
    @campaign = create(:campaign, boards: [@board], name: @campaign_name, project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json, starts_at: 3.days.from_now.beginning_of_day, ends_at: 5.days.from_now.beginning_of_day)
    assert_not @campaign.time_to_run?(@board)
  end
  test "time to run false minutes before start date" do
    minutes_for_next_day = ((Time.now.end_of_day - Time.now)/1.minute).ceil
    utc_offset = 60*minutes_for_next_day.div(60)
    @board = create(:board,project: @user.projects.first, name: "Board", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north", utc_offset: utc_offset)
    @campaign = create(:campaign, boards: [@board], name: @campaign_name, project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json, starts_at: 1.day.from_now.beginning_of_day, ends_at: 5.days.from_now.beginning_of_day)
    assert_not @campaign.time_to_run?(@board)
  end
  test "time to run true minutes after start date" do
    minutes_for_next_day = ((Time.now.end_of_day - Time.now)/1.minute).ceil
    utc_offset = 60*(minutes_for_next_day/60.0).ceil
    @board = create(:board,project: @user.projects.first, name: "Board", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", face: "north", utc_offset: utc_offset)
    @campaign = create(:campaign, boards: [@board], name: @campaign_name, project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json, starts_at: 1.day.from_now.beginning_of_day, ends_at: 5.days.from_now.beginning_of_day)
    assert @campaign.time_to_run?(@board)
  end
end
