require 'test_helper'

class EarningsProviderBilboTest < ActionDispatch::IntegrationTest
  setup do
    @name = "Provider"
    @user = create(:user, name: @name , email: "provider@bilbo.mx", roles: "provider")
    @project = @user.projects.first
    @board = create(:board, project: @project, name: "IOS OFFICE CORPORATIVO VIA (VIA) 1", lat: "32.521142", lng: "-117.0074563", avg_daily_views: "1", width: "1280", height: "720", address: "Misión de San Javier 10643, Zona Urbana Rio Tijuana, 22010 Tijuana, B.C., Mexico", category: "A", base_earnings: "207424", provider_earnings: "165939.6", face: "north", start_time: Time.zone.parse("8:00"), end_time: Time.zone.parse("20:00"))
    @board_2 = create(:board, project: @project, name: "IOS OFFICE CORPORATIVO VIA (VIA) 2", lat: "32.521142", lng: "-117.0074563", avg_daily_views: "1", width: "1280", height: "720", address: "Misión de San Javier 10643, Zona Urbana Rio Tijuana, 22010 Tijuana, B.C., Mexico", category: "A", base_earnings: "207424", provider_earnings: "165939.6", face: "north", start_time: Time.zone.parse("8:00"), end_time: Time.zone.parse("20:00"))
    @user_1 = create(:user, name: @name , email: "user@bilbo.mx", roles: "user")
    @project_1 = @user_1.projects.first

    @campaign = create(:campaign, name: "Campa0", project: @project, boards: [@board], classification: 0, provider_campaign: true, duration: 10, state: true, status: 0, budget_distribution: {"#{@board.id}": "400"}.to_json)
    @campaign_1 = create(:campaign, name: "Campa1", project: @project_1, boards: [@board], classification: 0, provider_campaign: false, duration: 10, state: true, status: 0)
    @campaign_3 = create(:campaign, name: "Campa3", project: @project_1, boards: [@board, @board_2], classification: 0, provider_campaign: false, duration: 10, state: true, status: 0, budget_distribution: {"#{@board.id}": "200", "#{@board_2.id}": "200"}.to_json)
    @user_2 = create(:user, name: @name , email: "user2@bilbo.mx", roles: "user")
    @project_2 = @user_2.projects.first
    @campaign_2 = create(:campaign, name: "Campa2", project: @project_2, boards: [@board], classification: 0, provider_campaign: false, duration: 10, state: true, status: 0, budget_distribution: {"#{@board.id}": "400"}.to_json)
  end

  test "complete earnings" do
    100.times do |count|
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_1.id, board_id: @board.id, created_at: Date.today + count.second , api_token: @board.api_token, duration: @campaign_1.duration)
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_2.id, board_id: @board.id, created_at: Date.today - 6.day + count.second , api_token: @board.api_token, duration: @campaign_2.duration)
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_3.id, board_id: @board.id, created_at: Date.today - 4.day + count.second , api_token: @board.api_token, duration: @campaign_3.duration)
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_3.id, board_id: @board_2.id, created_at: Date.today - 5.day + count.second , api_token: @board_2.api_token, duration: @campaign_3.duration)
    end
    assert_equal 640.0, Impression.all.sum(:total_price).round(2)
  end

  test "provider earnings " do
    100.times do |count|
     Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_1.id, board_id: @board.id, created_at: Date.today + count.second , api_token: @board.api_token, duration: @campaign_1.duration)
     Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_2.id, board_id: @board.id, created_at: Date.today - 6.day + count.second , api_token: @board.api_token, duration: @campaign_2.duration)
     Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_3.id, board_id: @board.id, created_at: Date.today - 4.day + count.second , api_token: @board.api_token, duration: @campaign_3.duration)
     Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_3.id, board_id: @board_2.id, created_at: Date.today - 5.day + count.second , api_token: @board_2.api_token, duration: @campaign_3.duration)
   end
    assert_equal 512.0, Board.provider_monthly_earnings_by_board(@project)
  end

  test "bilbo earnings" do
    100.times do |count|
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_1.id, board_id: @board.id, created_at: Date.today + count.second , api_token: @board.api_token, duration: @campaign_1.duration)
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_2.id, board_id: @board.id, created_at: Date.today - 6.day + count.second , api_token: @board.api_token, duration: @campaign_2.duration)
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_3.id, board_id: @board.id, created_at: Date.today - 4.day + count.second , api_token: @board.api_token, duration: @campaign_3.duration)
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_3.id, board_id: @board_2.id, created_at: Date.today - 5.day + count.second , api_token: @board_2.api_token, duration: @campaign_3.duration)
    end
    assert_equal 128.0, Board.monthly_earnings_by_board(@project) - Board.provider_monthly_earnings_by_board(@project)
  end

  test "provider earnings equals zero" do
    10.times do |count|
    Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign.id, board_id: @board.id, created_at: Date.today + count.second  , api_token: @board.api_token, duration: @campaign.duration)
   end
   assert_equal 0, Impression.all.sum(:provider_price)
   assert_equal 0, Impression.all.sum(:total_price)
  end

  test "monthly impressions" do
    10.times do |count|
    Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign.id, board_id: @board.id, created_at: Date.today - 1.day + count.second  , api_token: @board.api_token, duration: @campaign.duration)
   end
   assert_equal 10, Board.monthly_impressions(@project)
  end

  test "daily earnings" do
    1.times do |count|
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_3.id, board_id: @board.id, created_at: Date.today - 3.day + count.second , api_token: @board.api_token, duration: @campaign_3.duration)
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_3.id, board_id: @board_2.id, created_at: Date.today - 3.day + count.second , api_token: @board_2.api_token, duration: @campaign_3.duration)
    end
    assert_equal "{:impressions_count=>2, :gross_earnings=>2.56}", Board.daily_provider_earnings_by_boards(@project).first[1].to_s
  end

  test "user campaign earnings per hour" do
    @campaign_by_hour = create(:campaign, name: "1 Per Hour", project: @project_1, boards: [@board], classification: 2, provider_campaign: false, duration: 10, state: true, status: 0)
    100.times do |count|
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_by_hour.id, board_id: @board.id, created_at: Date.today - 3.day + count.second , api_token: @board.api_token, duration: @campaign_by_hour.duration)
      Impression.create(uuid: Faker::Alphanumeric.alpha(number: 15), campaign_id: @campaign_by_hour.id, board_id: @board.id, created_at: Date.today - 6.day + count.second , api_token: @board.api_token, duration: @campaign_by_hour.duration)
    end
    assert_equal 256.0, Board.provider_monthly_earnings_by_board(@project)
    assert_equal 320.0, Impression.all.sum(:total_price).round(2)
    assert_equal 64.0, Board.monthly_earnings_by_board(@project) - Board.provider_monthly_earnings_by_board(@project)
  end

end
