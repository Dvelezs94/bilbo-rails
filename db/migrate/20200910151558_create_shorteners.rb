class CreateShorteners < ActiveRecord::Migration[6.0]
  def change
    create_table :shorteners do |t|
      t.string :target_url
      t.string :token
      t.datetime :expires_at, default: 10.years.from_now

      t.timestamps
    end
  end
end
