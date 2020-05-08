class CreateVerifications < ActiveRecord::Migration[5.2]
  def change
    create_table :verifications do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :official_id
      t.string :business_name
      t.string :street_1
      t.string :street_2
      t.string :city
      t.string :state
      t.integer :zip_code
      t.string :country
      t.string :rfc
      t.string :business_code
      t.string :official_business_name
      t.string :website
      t.string :phone
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
