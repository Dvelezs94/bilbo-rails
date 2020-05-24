class Notification < ApplicationRecord
  include Rails.application.routes.url_helpers
  # the project has notifications so all users in the project can see them
  belongs_to :recipient, class_name: "Project"
  belongs_to :actor, class_name: "Project"
  belongs_to :notifiable, polymorphic: true
  # the reference can be any object that references to the notifiable object
  # for example notifiable can be Campaign and reference can be Board
  # that way we know that the notification belongs to campaign but also has a
  # board reference. It is used to create useful links
  belongs_to :reference, polymorphic: true, optional: true

  scope :unread, -> { where(read_at: nil) }
  # return all notifications by default on descending order by date
  default_scope { order("created_at DESC") }

  # builds the url and message for the notification
  # you can call a single element like this
  # notification.build_notification_body[:url] or notification.build_notification_body[:message]
  def build_notification_body
    translation = "notifications.#{notifiable_type}.#{action}".tr(' ', '_').downcase

    case notifiable_type
    when "Campaign"
      case action
      when "created"
        { url: provider_index_campaigns_path(q: "review"),
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message", campaign_name: notifiable.name) }
      when "accepted"
        { url: analytics_campaign_path(notifiable.slug),
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message") }
      when "denied"
        { url: analytics_campaign_path(notifiable.slug),
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message") }
      end
    when "User"
      case action
      when "out of credits"
        { url: provider_index_campaigns_path(q: "review"),
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message") }
      end
    when "Report"
      case action
      when "weekly ready"
        { url: provider_index_campaigns_path(q: "review"),
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message") }
      end
    end
  end

  def read!
    self.update(read_at: Time.now)
  end

  private
  def notificate_by_email
    NotificationMailer.deliver()
  end
end
