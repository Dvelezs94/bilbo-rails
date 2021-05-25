class WitnessDaysVerificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform
    pending_witnesses = []
    Witness.all.where(status: 0).each do |witness|
      if witness.created_at < 3.days.ago
        pending_witnesses.push(witness.campaign.name)
      end
    end
    if Rails.env.production? && pending_witnesses.present?
      SlackNotifyWorker.perform_async("Las campañas: #{pending_witnesses} llevan más de tres días que solicitaron testigos")
    end
  end
end
