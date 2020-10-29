class AddAdsRotationUpdatedAtToBoard < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :ads_rotation_updated_at, :datetime
  end
end
