class SyncEmailContactsWorker
  include Sidekiq::Worker
  include SendgridHelper
  include MailerliteHelper
  sidekiq_options retry: false, dead: false

  def perform
    User.where.not(roles: "admin").each do |user|
      sync_mailerlite_user(user)
    end
  end
end
