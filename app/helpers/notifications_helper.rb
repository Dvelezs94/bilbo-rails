module NotificationsHelper
  def create_notification(recipient_id:, actor_id:, action:, notifiable:, reference: nil)
    Notification.create(recipient_id: recipient_id, actor_id: actor_id, action: action, notifiable: notifiable, reference: reference)
  end
end
