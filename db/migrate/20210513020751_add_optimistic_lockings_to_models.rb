class AddOptimisticLockingsToModels < ActiveRecord::Migration[6.0]
  def change
    add_column :campaigns, :lock_version, :integer
    add_column :impressions, :lock_version, :integer
    add_column :users, :lock_version, :integer
  end
end
