class AddStatusToAds < ActiveRecord::Migration[5.2]
  def change
    add_column :ads, :status, :integer, default: 0
  end
end
