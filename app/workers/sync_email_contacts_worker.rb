class SyncEmailContactsWorker
  include Sidekiq::Worker
  include SendgridHelper
  include MailerliteHelper
  sidekiq_options retry: false, dead: false

  def perform
    MailerliteHelper.sync_all()
  end
end
