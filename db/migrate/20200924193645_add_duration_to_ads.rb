class AddDurationToAds < ActiveRecord::Migration[6.0]
  def change
    add_column :ads, :duration, :integer, default: 10
  end
end
