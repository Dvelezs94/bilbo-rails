class CreateCampaigns < ActiveRecord::Migration[5.2]
  def change
    create_table :campaigns do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :description
      t.float :budget
      # status is for internal status, like in review, accepted or denied
      t.integer :status, default: 0
      # state is for user desired state of the campaign, enabled or disabled
      t.boolean :state, null: false, default: false
      t.string :decline_comment
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
  end
end
