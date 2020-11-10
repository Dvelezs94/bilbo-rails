require 'test_helper'

class CampaignSubscriberTest < ActiveSupport::TestCase
  setup do
    @campaign_name = "Campaign subscriber"
    @name = "Subscriber"
    @phone_number = "+528442467244"
    @project = create(:project, name: @name)
    @campaign = create(:campaign, name: @campaign_name, project: @project)
    @campaign_subscriber = create(:campaign_subscriber,campaign: @campaign, name: @name , phone_number: @phone_number, id: 5)
  end
  test "has phone" do
    assert_equal @phone_number, @campaign.subscribers.last.phone_number
  end
 test "has campaign" do
   assert_equal @name, @campaign_subscriber.name
 end
end
