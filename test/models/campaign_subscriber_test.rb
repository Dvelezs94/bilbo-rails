require 'test_helper'

class CampaignSubscriberTest < ActiveSupport::TestCase
  setup do
    @campaign_name = "Campaign subscriber"
    @name = "Subscriber"
    @phone = "+528442467244"
    @project = create(:project, name: @name, status: "enabled")
    @campaign = create(:campaign, name: @campaign_name, project: @project)
    @campaign_subscriber = create(:campaign_subscriber,campaign: @campaign, name: @name , phone: @phone, id: 5)
  end
  test "has phone" do 
    assert_equal @phone, @campaign.subscribers.last.phone
  end
 test "has campaign" do
   assert_equal @name, @campaign_subscriber.name
 end
end
