class Notification < ApplicationRecord
  include Rails.application.routes.url_helpers
  include ApplicationHelper
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

  after_commit :notificate_recipients, on: :create

  def read!
    self.update(read_at: Time.now)
  end

  def user
    recipient.owner
  end

  # builds the url and message for the notification
  # you can call a single element like this
  # notification.build_notification_body[:url] or notification.build_notification_body[:message]
  def build_notification_body(lang: ENV.fetch("RAILS_LOCALE") )
    I18n.locale = lang
    translation = "notifications.#{notifiable_type}.#{action}".tr(' ', '_').downcase
    case notifiable_type
    when "Campaign"
      case action
      when "created"
        { url: provider_index_campaigns_url(q: "review"),
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message", campaign_name: notifiable.name),
          subject: I18n.t("#{translation}.subject", campaign_name: notifiable.name) }
      when "approved"
        { url: analytics_campaign_url(notifiable.slug),
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message", campaign_name: notifiable.name, bilbo_name: reference.name),
          subject: I18n.t("#{translation}.subject", campaign_name: notifiable.name, bilbo_name: reference.name) }
      when "denied"
        { url: analytics_campaign_url(notifiable.slug),
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message", campaign_name: notifiable.name, bilbo_name: reference.name),
          subject: I18n.t("#{translation}.subject", campaign_name: notifiable.name, bilbo_name: reference.name) }
      when "time campaign error"
        { url: campaigns_url,
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message", campaign_name: notifiable.name),
          subject: I18n.t("#{translation}.subject", campaign_name: notifiable.name) }
      end
    when "User"
      case action
      when "out of credits"
        { url: campaigns_url(credits: "true"),
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message"),
          subject: I18n.t("#{translation}.subject") }
      when "csv ready"
      { url: download_csv_csv_index_url(reference: reference.name),
        url_string: I18n.t("#{translation}.url_string"),
        message: I18n.t("#{translation}.message"),
        subject: I18n.t("#{translation}.subject") }
      end
    when "Project"
      case action
      when "new invite"
        { url: change_project_project_url(notifiable.id),
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message", user_name: reference.name_or_email),
         subject: I18n.t("#{translation}.subject", user_name: reference.name_or_email) }
      when "invite removed"
        { url: change_project_project_url(notifiable.id),
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message", user_name: reference.email),
         subject: I18n.t("#{translation}.subject", user_name: reference.email) }
      when "evidences"
        { url: campaigns_url(evidence: "true", witness: reference),
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message", campaign_name: reference.campaign.name),
         subject: I18n.t("#{translation}.subject", campaign_name: reference.campaign.name) }
       when "witness"
         { url: analytics_campaign_url(reference.slug),
           url_string: I18n.t("#{translation}.url_string"),
           message: I18n.t("#{translation}.message", campaign_name: reference.name),
          subject: I18n.t("#{translation}.subject", campaign_name: reference.name) }
      end
    when "Report"
      case action
      when "weekly ready"
        { url: provider_index_campaigns_url(q: "review"),
          url_string: I18n.t("#{translation}.url_string"),
          message: I18n.t("#{translation}.message"),
        subject: I18n.t("#{translation}.subject") }
      end
    end
    end
  end

  private

  def notificate_recipients
    # notify each user by email
     notif_body = self.build_notification_body
    recipient.users.each do |user|
      NotificationMailer.new_notification(user: user, message: ActionView::Base.full_sanitizer.sanitize(notif_body[:message]),
        subject: ActionView::Base.full_sanitizer.sanitize(notif_body[:subject]),
        link: notif_body[:url], link_text: notif_body[:url_string]).deliver

      if sms && user.phone_number.present?
        send_sms(user.phone_number, "#{ActionView::Base.full_sanitizer.sanitize(notif_body[:message])}. #{notifications_url}")
      end
    end
  end
