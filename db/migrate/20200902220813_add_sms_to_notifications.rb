class AddSmsToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :sms, :boolean, default: false
  end
end
