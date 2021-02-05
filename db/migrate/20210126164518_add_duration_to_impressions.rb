class AddDurationToImpressions < ActiveRecord::Migration[6.0]
  def change
    add_column :impressions, :duration, :integer
  end
end
