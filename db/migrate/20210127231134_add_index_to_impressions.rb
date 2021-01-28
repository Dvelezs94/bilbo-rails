class AddIndexToImpressions < ActiveRecord::Migration[6.0]
  def change
    add_index :impressions, [:created_at, :board_id], unique: true
  end
end
