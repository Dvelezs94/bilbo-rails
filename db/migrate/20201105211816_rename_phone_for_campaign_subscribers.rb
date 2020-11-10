class RenamePhoneForCampaignSubscribers < ActiveRecord::Migration[6.0]
  def change
    change_table :campaign_subscribers do |t|
      t.rename :phone, :phone_number
    end
  end
end
