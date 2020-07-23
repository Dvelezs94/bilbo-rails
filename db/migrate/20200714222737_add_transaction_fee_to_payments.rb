class AddTransactionFeeToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :transaction_fee, :float
  end
end
