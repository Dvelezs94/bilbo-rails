class GenerateInvoiceWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, dead: false

  def perform(payment_id)
    @payment = Payment.find(payment_id)
    Invoice.create(payment_id: @payment.id, user_id: @payment.user_id)
  end
end
