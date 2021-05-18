class CreateWitnesses < ActiveRecord::Migration[6.0]
  def change
    create_table :witnesses do |t|
      t.integer :status, default: 0
      t.string :slug
      t.references :campaign, null: false, foreign_key: true
      t.timestamps
    end
    add_index :witnesses, :slug, unique: true
  end
end
