class AddCustomMessageToNotification < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :custom_message, :string
  end
end
