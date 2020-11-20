require 'test_helper'

class CampaignSubscriberTest < ActiveSupport::TestCase
  setup do
    @project = create(:project, name: "Subscriber")
    @campaign = create(:campaign, project: @project)
  end

  test "has phone" do
    @phone_number = "+528442864004"
    @campaign_subscriber = create(:campaign_subscriber, campaign: @campaign, phone_number: @phone_number)
    assert_equal @phone_number, @campaign_subscriber.phone_number
  end

  test "has name" do
    @subscriber_name = "test name"
    @campaign_subscriber = create(:campaign_subscriber, campaign: @campaign, name: @subscriber_name)
    assert_equal @subscriber_name, @campaign_subscriber.name
  end
end
