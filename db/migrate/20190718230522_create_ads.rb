class CreateAds < ActiveRecord::Migration[5.2]
  def change
    create_table :ads do |t|
      t.string :name
      t.string :description
      t.references :project, foreign_key: true
      t.string :multimedia

      t.timestamps
    end
  end
end
