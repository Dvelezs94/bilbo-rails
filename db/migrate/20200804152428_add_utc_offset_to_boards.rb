class AddUtcOffsetToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :utc_offset, :integer
  end
end
