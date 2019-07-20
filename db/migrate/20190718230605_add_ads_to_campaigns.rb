class AddAdsToCampaigns < ActiveRecord::Migration[5.2]
  def change
    add_reference :campaigns, :ad, foreign_key: true
  end
end
