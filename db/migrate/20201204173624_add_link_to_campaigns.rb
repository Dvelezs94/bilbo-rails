class AddLinkToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :link, :string
    add_column :campaigns, :objective, :integer, default: 0
  end
end
