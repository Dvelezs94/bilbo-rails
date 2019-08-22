class CreateImpressions < ActiveRecord::Migration[5.2]
  def change
    create_table :impressions do |t|
      t.references :campaign, foreign_key: true
      t.references :board, foreign_key: true
      t.integer :cycles, default: 1
      # we only need created_at in this model
      t.datetime :created_at, null: false
    end
  end
end
