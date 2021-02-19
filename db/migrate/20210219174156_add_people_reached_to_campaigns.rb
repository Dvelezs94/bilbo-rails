class AddPeopleReachedToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :people_reached, :integer, default: 0
  end
end
