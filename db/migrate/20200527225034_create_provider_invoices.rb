class CreateProviderInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :provider_invoices do |t|
      t.references :user, foreign_key: true
      t.integer :issuing_id
      t.string :documents
      t.references :campaign, foreign_key: true
      t.string :comments
      t.string :uuid

      t.timestamps
    end
  end
end
