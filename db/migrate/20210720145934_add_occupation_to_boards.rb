class AddOccupationToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :occupation, :float, default: 0.0
  end
end
