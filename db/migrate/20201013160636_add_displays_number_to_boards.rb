class AddDisplaysNumberToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :displays_number, :int, default: 1
  end
end
