class CreateJoinTableAdArtwork < ActiveRecord::Migration[5.2]
  def change
    create_join_table :ads, :artworks do |t|
      t.index [:ad_id, :artwork_id]
      t.index [:artwork_id, :ad_id]
    end
  end
end
