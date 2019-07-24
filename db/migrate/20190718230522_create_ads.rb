class CreateAds < ActiveRecord::Migration[5.2]
  def change
    create_table :ads do |t|
      t.string :name
      t.integer :status, default: 0
      t.string :decline_comment
      t.references :user, foreign_key: true
      t.string :multimedia

      t.timestamps
    end
  end
end
