class SyncSendgridContactsWorker
  include Sidekiq::Worker
  include SendgridHelper
  sidekiq_options retry: false, dead: false

  def perform
    User.where.not(roles: "admin").each do |user|
      sync_sendgrid_contacts(user)
    end
  end
end
