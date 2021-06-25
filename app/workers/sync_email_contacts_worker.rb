class SyncEmailContactsWorker
  include Sidekiq::Worker
  include SendgridHelper
  include MailerliteHelper
  sidekiq_options retry: false, dead: false

  def perform
    User.where.not(roles: "admin").each do |user|
      puts user.email
      begin
        sync_mailerlite_user(user)
      rescue MailerLite::BadRequest => e
        Bugsnag.notify("Mailerlite error for user #{user.email}: #{e}")
      end
    end
  end
end
