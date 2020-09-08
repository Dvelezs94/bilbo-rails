class CreateImpressionHours < ActiveRecord::Migration[6.0]
  def change
    create_table :impression_hours do |t|
      t.time :start
      t.time :end
      t.integer :imp
      t.integer :day
      t.references :campaign, null: false, foreign_key: true

      t.timestamps
    end
  end
end
