class CreateWitnesses < ActiveRecord::Migration[6.0]
  def change
    create_table :witnesses do |t|
      t.integer :status, default: 0
      t.references :campaign, null: false, foreign_key: true
      t.timestamps
    end
  end
end
