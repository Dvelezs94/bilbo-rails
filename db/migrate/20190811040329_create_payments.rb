class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.float :total
      t.references :user, foreign_key: true
      t.string :paid_with

      t.timestamps
    end
  end
end
