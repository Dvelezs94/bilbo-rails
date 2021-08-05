class ChangeDataTypeForPeopleReached < ActiveRecord::Migration[6.0]
  def change
    change_column :campaigns, :people_reached, :float, default: 0
  end
end
