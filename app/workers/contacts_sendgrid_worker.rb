class ContactsSendgridWorker
  include Sidekiq::Worker
  include ListHelper
  sidekiq_options retry: false, dead: false

  def perform
    User.where.not(roles: "admin").each do |user|
      contact_sendgrid(user)
    end
  end
end
