class AddUuidToImpressions < ActiveRecord::Migration[6.0]
  def change
    add_column :impressions, :uuid, :string, unique: true
    add_index :impressions, :uuid, :unique => true
  end
end
