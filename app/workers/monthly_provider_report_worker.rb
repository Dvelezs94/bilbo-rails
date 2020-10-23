class MonthlyProviderReportWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform
    Project.provider.each do |pr|
      pr.owner.send_provider_report(method: :email)
    end
  end
end
