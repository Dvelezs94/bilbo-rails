class AddProcessedToActiveStorageAttachments < ActiveRecord::Migration[6.0]
  def change
    add_column :active_storage_attachments, :processed, :boolean, default: false
  end
end
