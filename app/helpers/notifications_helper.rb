module NotificationsHelper
  def create_notification(recipient_id:, actor_id:, action:, notifiable:, reference: nil, sms: false)
    Notification.create(recipient_id: recipient_id, actor_id: actor_id, action: action, notifiable: notifiable, reference: reference, sms: sms)
  end
end
