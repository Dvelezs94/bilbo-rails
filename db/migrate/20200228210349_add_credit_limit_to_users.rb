class AddCreditLimitToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :credit_limit, :int, default: 100
  end
end
