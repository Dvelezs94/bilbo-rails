require 'test_helper'

class CampaignSubscriberTest < ActiveSupport::TestCase
  setup do
    @project = create(:project, name: "Subscriber")
    @campaign = create(:campaign, project: @project)
  end

  test "has phone" do
    @campaign_subscriber = create(:campaign_subscriber, campaign: @campaign, phone_number: "+528442864004")
    assert_equal @campaign_subscriber.phone_number.present?, @campaign_subscriber.phone_number.present?
  end

  test "has name" do
    @subscriber_name = "test name"
    @campaign_subscriber = create(:campaign_subscriber, campaign: @campaign, name: @subscriber_name, phone_number: "+528442864005")
    assert_equal @subscriber_name, @campaign_subscriber.name
  end
end
