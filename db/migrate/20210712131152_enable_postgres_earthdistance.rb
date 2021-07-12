class EnablePostgresEarthdistance < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'cube';
    enable_extension 'earthdistance';
  end
end
