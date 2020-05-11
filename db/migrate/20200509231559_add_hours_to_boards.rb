class AddHoursToBoards < ActiveRecord::Migration[5.2]
  def change
    add_column :boards, :working_hours, :float
  end
end
