class AddStatusToPayment < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :status, :integer, default: 0
    add_column :payments, :spei_reference, :string
  end
end
