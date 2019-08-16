class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.integer :total
      t.references :user, foreign_key: true
      t.string :paid_with
      t.string :express_token
      t.string :express_payer_id
      t.inet :ip
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
