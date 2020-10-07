class AddSetUpAccountToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :business_type, :int
    add_column :users, :company_name, :string
    add_column :users, :work_position, :string
    add_column :users, :payment_preference, :string
  end
end
