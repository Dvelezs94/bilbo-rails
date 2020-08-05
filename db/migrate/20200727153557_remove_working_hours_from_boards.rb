class RemoveWorkingHoursFromBoards < ActiveRecord::Migration[6.0]
  def change
    remove_column :boards, :working_hours, :float
  end
end
