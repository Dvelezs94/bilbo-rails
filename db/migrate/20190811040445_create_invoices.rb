class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.string :invoice_number
      t.references :payment, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
