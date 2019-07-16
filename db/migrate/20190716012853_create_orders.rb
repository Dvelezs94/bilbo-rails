class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.integer :status
      t.references :campaign, foreign_key: true
      t.integer :prints
      t.float :total
      t.datetime :paid_at

      t.timestamps
    end
  end
end
