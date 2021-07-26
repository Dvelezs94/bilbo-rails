require 'test_helper'

class BoardTest < ActiveSupport::TestCase
  setup do
    @name = "Ussopn"
    @project =  create(:project, name: @name)
    @campaign_name = "Pirate hunter"
    @user = create(:user,role: "provider", name: @name, balance: "5000")
    @board = create(:board,project: @user.projects.first, name: "Board", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720", address: "mineria 908", category: "A", base_earnings: "5000", provider_earnings: "4000", face: "north")
  end

  test "provider campaign occupation" do
    @campaign = create(:campaign, name: @campaign_name, project: @user.projects.first, boards: [@board], state: true, status: "active", provider_campaign: true, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json)
    @campaign.board_campaigns.update(budget: @board.minimum_budget, status: "approved")
    @board.update(occupation: @board.new_occupation)
    assert_equal @board.occupation, @campaign.board_campaigns.first.max_daily_impressions.to_f * 100.0 / JSON.parse(@board.ads_rotation).length
  end

  test "user campaign occupation" do
    @campaign = create(:campaign, name: @campaign_name, project: @user.projects.first, boards: [@board], state: true, status: "active", provider_campaign: false, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json)
    @campaign.board_campaigns.update(budget: @board.minimum_budget, status: "approved")
    @board.update(occupation: @board.new_occupation)
    assert_equal @board.occupation, @campaign.board_campaigns.first.max_daily_impressions.to_f * 100.0 / JSON.parse(@board.ads_rotation).length
  end

  test "occupation doesnt change with impressions" do
    @campaign = create(:campaign, name: @campaign_name, project: @user.projects.first, boards: [@board], state: true, status: "active", provider_campaign: false, budget_distribution: {"#{@board.id}": "#{@board.minimum_budget}"}.to_json)
    @campaign.board_campaigns.update(budget: @board.minimum_budget, status: "approved")
    occupation_start = @board.new_occupation
    start_time = Time.parse(@board.start_time.strftime("%H:%M")) - @board.utc_offset.minutes
    end_time = Time.parse(@board.end_time.strftime("%H:%M")) - @board.utc_offset.minutes
    [100, @campaign.remaining_impressions(@board)].min.times do
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign.id, board_id: @board.id, created_at: rand_time(start_time-1.day, end_time-1.day), api_token: @board.api_token, duration: @campaign.duration)
    end
    occupation_end = @board.new_occupation
    assert_equal occupation_start, occupation_end
  end
end
