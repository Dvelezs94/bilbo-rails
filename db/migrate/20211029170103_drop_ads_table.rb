class DropAdsTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :ads, force: :cascade
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
