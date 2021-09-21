class AddTaggifyUrlToBoard < ActiveRecord::Migration[6.0]
  def change
    add_column :boards, :taggify_url, :string
  end
end
