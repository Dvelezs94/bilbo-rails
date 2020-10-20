require 'test_helper'

class CampaignTest < ActiveSupport::TestCase
  i_suck_and_my_tests_are_order_dependent!
  include Rails.application.routes.url_helpers
  setup do 
    @name = "Ussopn"
    @campaign_name = "Pirate hunter"
    @project_id = "2"
    @project =  create(:project, name: @name, id: @project_id)
    @user = create(:user,role: "provider", name: @name)
    @campaign = create(:campaign, name: @campaign_name,project: @user.projects.first, project_id: @project_id)
  end
  test "is provider" do
    assert @user.is_provider?
  end
  test "create budget campaign" do
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, clasification: 0 )
    assert_equal "budget", @campaign.clasification
  end
  test "create per minute campaign" do 
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, clasification: 1 )
    assert_equal "per_minute", @campaign.clasification
  end
  test "create per hour campaign" do 
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, clasification: 2 )
    assert_equal "per_hour", @campaign.clasification
  end
  test "has board" do
    @board = create(:board,project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A
      ", base_earnings: "5000", face: "north")
      assert 1, @campaign.boards.count
  end
  test "has creative" do
    @ad = create(:ad, name: "Coca-Cola", project: @user.projects.first)
    assert true, @campaign.has_multimedia? 
  end
  test "should run" do
    @board_id = "30"
    @board = create(:board,project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A
      ", base_earnings: "5000", face: "north", id: @board_id)
      assert true, @campaign.should_run?(@board_id)
  end
  test "project status" do
    @campaign.project_status
    assert "Tu creativo no cuenta con imágenes para correr en los bilbos que no admiten video"
  end
  test "on going campaign" do
    @campaign =  create(:campaign, name: "budget campaign", project: @user.projects.first, clasification: 0, starts_at: "2020-10-10 05:00:00", ends_at: "2020-10-11 05:00:00")
    assert_equal false, @campaign.ongoing?
  end
  test "user has budget" do 
    @user = create(:user, name: "Luffy", balance: "7777")
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, clasification: 0)
    assert_equal true, @campaign.user_has_budget?
  end
  test "state off when campaign created" do
    @campaign = create(:campaign, name: "TRUNKS", project: @user.projects.first)
    assert true, @campaign.off
  end
  test "owner" do
    @id = "18"
    @user = create(:user, name: "Zoro", id: @id)
    @campaign = create(:campaign, name: "wano", project: @user.projects.first)
    assert_equal @user, @campaign.owner
  end
  test "budget campaign has correct fields" do
    @budget = "500"
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, clasification: 0, budget: @budget)
      assert @budget, @campaign.budget
  end
  test "per minute campaign has correct fields" do
    @imp = 5
    @minutes = 5
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, clasification: 1, imp: @imp, minutes: @minutes)
      assert_equal @imp, @campaign.imp
      assert_equal @minutes, @campaign.minutes
  end
  test "per hour campaign has imp" do
    @imp = 5
    @end = "17:00"
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, clasification: 1)
    @impression_hour = create(:impression_hour,campaign: @campaign , imp: @imp, end: @end)
      assert @imp, @campaign.impression_hours.last
  end
  test "per hour campaign has start" do
    @start = "2000-01-01 13:00:00 -0600"
    @end = "17:00"
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, clasification: 1)
    @impression_hour = create(:impression_hour,campaign: @campaign , start: @start, end: @end)
      assert_equal @start, @campaign.impression_hours.last.start.to_s
  end
  test "per hour campaign has end" do
    @end = "2000-01-01 17:00:00 -0600"
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, clasification: 1)
    @impression_hour = create(:impression_hour,campaign: @campaign , end: @end)
      assert_equal @end, @campaign.impression_hours.last.end.to_s
  end
  test "per hour campaign has day" do
    @day = "monday"
    @end = "17:00"
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, clasification: 1)
    @impression_hour = create(:impression_hour,campaign: @campaign , day: @day, end: @end)
      assert_equal @day, @campaign.impression_hours.last.day
  end
  test "cant update when is active"do
    @campaign = create(:campaign, name: @campaign_name,project: @user.projects.first, project_id: @project_id, state: true)
    assert "La campaña no puede editarse cuando está activa", @campaign.cant_update_when_active
  end
  test "build ad rotation" do
      assert_not nil, @campaign.check_build_ad_rotation
  end
  test "off method" do
    @camp1 = create(:campaign, name: "off",project: @user.projects.first, project_id: @project_id, state: false)
    assert true, @camp1.off
  end
  test "on method" do
    @camp2 = create(:campaign, name: "on",project: @user.projects.first, project_id: @project_id, state: true)
    assert true, @camp2.on
  end
  test "campaign cant be active when ad missing" do
    @campaign_ad = create(:campaign, name: "skypea", project: @user.projects.first)
    assert_equal false, @campaign_ad.state
  end
end



