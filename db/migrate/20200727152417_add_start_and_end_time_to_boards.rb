class AddStartAndEndTimeToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :start_time, :time
    add_column :boards, :end_time, :time
  end
end
