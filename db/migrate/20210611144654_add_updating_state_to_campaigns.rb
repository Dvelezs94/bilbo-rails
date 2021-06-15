class AddUpdatingStateToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :updating_state, :boolean, default: false
  end
end
