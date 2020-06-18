class CreateUserActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :user_activities do |t|
      t.string :activity
      t.integer :activeness_id
      t.string :activeness_type
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
