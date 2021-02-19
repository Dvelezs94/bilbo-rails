require 'test_helper'

class CampaignsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @campaign_name = "Zoro"
    @user = create(:user, name: @campaign_name )
    @board = create(:board,project: @user.projects.first, name: "LUFFY", lat: "180558", lng: "18093", avg_daily_views: "800000", width: "1280", height: "720",
      address: "mineria 908", category: "A", base_earnings: "5000", face: "north")
    @project =  create(:project, name: @campaign_name)
    @campaign = create(:campaign, name: @campaign_name,project: @user.projects.first, project_id: @project.id, provider_campaign: @user.is_provider?)
    sign_in @user
  end

  test "Campaign Name" do
    @campaign = create(:campaign, name: "controller",project: @user.projects.first, project_id: @project.id, state: true, provider_campaign: @user.is_provider?)
    assert @campaign.name, @campaign_name
  end
  test "campaign index" do
    get campaigns_url
    assert_response :success
  end
  test "provider index"do
    @user2 = create(:user,name: @campaign_name, email: "#{name}@bilbo.mx".downcase, roles: "provider")
    sign_in @user2
    get provider_index_campaigns_url
    assert_response :success
  end
  test "get analytics" do
    get analytics_campaign_url(@campaign.id)
    assert_response :success
  end
  test "deny access without log in" do
    sign_out :user
    get campaigns_url
    assert_response :redirect
  end

  test "copy budget campaign" do
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, clasification: 0, provider_campaign: @user.is_provider?)
    post create_copy_campaign_path(@campaign), params: {campaign: {name: "CopyCampaign 1", description: "XXXXXXX"} }
    #get the new record (the one we created in the previous line)
    campaign_2 = Campaign.find_by(name: "CopyCampaign 1")
    attributes_1 = @campaign.attributes.delete_if{|key, value| !["project_id", "budget", "starts_at", "ends_at", "ad_id", "provider_campaign", "clasification", "objective"].include?(key)}
    attributes_1.merge({boards: @campaign.boards.pluck(:id).sort})
    attributes_2 = campaign_2.attributes.delete_if{|key, value| !["project_id", "budget", "starts_at", "ends_at", "ad_id", "provider_campaign", "clasification", "objective"].include?(key)}
    attributes_2.merge({boards: campaign_2.boards.pluck(:id).sort})
    assert_equal attributes_1, attributes_2
  end

  test "copy campaign per minute" do
    @campaign = create(:campaign, name: "campaign per minute", project: @user.projects.first, clasification: 1, provider_campaign: @user.is_provider?, imp: 3, minutes: 2)
    post create_copy_campaign_path(@campaign), params: {campaign: {name: "CopyCampaign 2", description: "XXXXXXX"} }
    #get the new record (the one we created in the previous line)
    campaign_2 = Campaign.find_by(name: "CopyCampaign 2")
    attributes_1 = @campaign.attributes.delete_if{|key, value| !["project_id", "imp", "minutes", "starts_at", "ends_at", "ad_id", "provider_campaign", "clasification", "objective"].include?(key)}
    attributes_1.merge({boards: @campaign.boards.pluck(:id).sort})
    attributes_2 = campaign_2.attributes.delete_if{|key, value| !["project_id", "imp", "minutes", "starts_at", "ends_at", "ad_id", "provider_campaign", "clasification", "objective"].include?(key)}
    attributes_2.merge({boards: campaign_2.boards.pluck(:id).sort})
    assert_equal attributes_1, attributes_2
  end

  test "copy campaign per hour" do
    @campaign = create(:campaign, name: "campaign per hour", project: @user.projects.first, clasification: 2, provider_campaign: @user.is_provider?)
    @campaign.impression_hours.create(start: "2000-01-01 09:00:00", end: "2000-01-01 11:00:00", imp: 200, day: "everyday")
    @campaign.impression_hours.create(start: "2000-01-01 11:00:00", end: "2000-01-01 13:00:00", imp: 200, day: "everyday")
    @campaign.impression_hours.create(start: "2000-01-01 13:00:00", end: "2000-01-01 15:00:00", imp: 200, day: "everyday")
    post create_copy_campaign_path(@campaign), params: {campaign: {name: "CopyCampaign 3", description: "XXXXXXX"} }
    #get the new record (the one we created in the previous line)
    campaign_2 = Campaign.find_by(name: "CopyCampaign 3")
    #Validate parameters of the campaigns
    attributes_1 = @campaign.attributes.delete_if{|key, value| !["project_id", "imp", "minutes", "starts_at", "ends_at", "ad_id", "provider_campaign", "clasification", "objective"].include?(key)}
    attributes_1.merge({boards: @campaign.boards.pluck(:id).sort})
    attributes_2 = campaign_2.attributes.delete_if{|key, value| !["project_id", "imp", "minutes", "starts_at", "ends_at", "ad_id", "provider_campaign", "clasification", "objective"].include?(key)}
    attributes_2.merge({boards: campaign_2.boards.pluck(:id).sort})
    assert_equal attributes_1, attributes_2
    #Valide parameters from impression_hours
    attributes_1 = @campaign.impression_hours.pluck(:start, :end, :imp, :day).sort_by{|v| v[0]}
    attributes_2 = campaign_2.impression_hours.pluck(:start, :end, :imp, :day).sort_by{|v| v[0]}
    assert_equal attributes_1, attributes_2
  end

  test "differences in copies" do
    @campaign = create(:campaign, name: "budget campaign", project: @user.projects.first, clasification: 0, provider_campaign: @user.is_provider?)
    post create_copy_campaign_path(@campaign), params: {campaign: {name: "CopyCampaign 4", description: "XXXXXXX"} }
    #get the new record (the one we created in the previous line)
    campaign_2 = Campaign.find_by(name: "CopyCampaign 4")
    different_ids = @campaign.id != campaign_2.id
    different_names = @campaign.name != campaign_2.name
    different_descriptions = @campaign.description != campaign_2.description
    assert different_ids #Campaigns must have the same parameters, but the id can't be the same
    assert different_names
    assert different_descriptions
    assert_equal campaign_2.state, false
    assert_equal campaign_2.impression_count, 0
  end
end
