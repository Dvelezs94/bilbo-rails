module NotificationsHelper
  def create_notification(recipient_id:, actor_id:, action:, notifiable:, reference: nil, sms: false, custom_message: nil)
    Notification.create(recipient_id: recipient_id, actor_id: actor_id, action: action, notifiable: notifiable, reference: reference, sms: sms, custom_message: custom_message)
  end
end
