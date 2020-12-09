class CreateSales < ActiveRecord::Migration[6.0]
  def change
    create_table :sales do |t|
      t.integer :percent
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :description

      t.timestamps
    end
  end
end
