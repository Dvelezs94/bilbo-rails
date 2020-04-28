class AddTransitionToActiveStorageAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :active_storage_attachments, :transition, :integer, default: 0
  end
end
