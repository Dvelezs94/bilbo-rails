class CampaignToggleStateWorker
  include Sidekiq::Worker
  include NotificationsHelper
  sidekiq_options retry: 3
  attr_accessor :retry_count

  # the retry_count increases every attempt by one except on the first one {0,0,1,2,3,4,...}
  # reference https://stackoverflow.com/questions/23065578/sidekiq-retry-count-in-job
  def retry_count
    @retry_count || 0
  end

  def perform(campaign_id,user_id)
    return if retry_count > 1
    campaign = Campaign.find(campaign_id)
    user = User.find(user_id)
    begin
      campaign.with_lock do
        if !campaign.state
          @success = campaign.update(state: !campaign.state, skip_review: true, user_locale: user.locale) #Only skips the 'set_in_review_and_update_price' callback, THIS DOES NOT SKIP ALL VALIDATIONS
        else
          campaign.state = false
          @success = campaign.save(validate: false, user_locale: user.locale) #Does not run any validation, just turns off the campaign and updates the ads_rotation of every associated board
          campaign.boards.each do |b|
            b.update_ads_rotation(false, user.locale)
          end
        end
      end
    rescue => e
      Bugsnag.notify(e)
      e.instance_eval {def skip_bugsnag; true; end }
      raise e if retry_count != 1
    ensure
      campaign.update_column(:updating_state, false)
    end
    if @success
      if campaign.state
        create_notification(recipient_id: campaign.project_id, actor_id: campaign.project_id, action: "state on successfully", notifiable: campaign, reference: user)
      else
        create_notification(recipient_id: campaign.project_id, actor_id: campaign.project_id, action: "state off successfully", notifiable: campaign, reference: user)
      end
    else
      create_notification(recipient_id: campaign.project_id, actor_id: campaign.project_id, action: "toggle state failed", notifiable: campaign, reference: user, custom_message: campaign.errors.full_messages.last)
    end
  end
end
