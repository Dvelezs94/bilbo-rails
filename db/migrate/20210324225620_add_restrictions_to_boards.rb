class AddRestrictionsToBoards < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :restrictions, :string
  end
end
