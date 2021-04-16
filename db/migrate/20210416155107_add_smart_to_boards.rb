class AddSmartToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :smart, :boolean, default: true
  end
end
