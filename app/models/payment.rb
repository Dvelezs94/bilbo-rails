class Payment < ApplicationRecord
  belongs_to :user
  has_one :invoice, :dependent => :destroy
  validates :express_token, uniqueness: true, if: -> { paid_with == "Paypal Express" }
  validate :one_payment_at_a_time, on: :create
  before_save :notify_on_slack, if: :will_save_change_to_spei_reference?
  include ApplicationHelper
  require 'json'

  enum status: { waiting_for_payment: 0, reviewing_payment: 1, paid: 2, rejected: 3, cancelled: 4  }

  scope :pending_payments, -> { where(status: "waiting_for_payment") }

  def purchase
    if paid_with == "Paypal Express"
      response = EXPRESS_GATEWAY.purchase((total + payment_fee(total)) * 100, express_purchase_options)
      if response.success?
        self.paid!
        if user.balance < 5
          user.add_credits(total)
          user.resume_campaigns
        else
          user.add_credits(total)
        end
      GenerateInvoiceWorker.perform_async(id)
      else
        self.rejected!
        # for debugging
        puts response.message
      end
      response.success?
    end
  end


  def total_in_cents
    ActionController::Base.helpers.number_to_currency(self.total, precision: 2, separator: ".", delimiter: ",", format: "%n")
  end

  def express_token=(token)
    self[:express_token] = token
    if new_record? && !token.blank?
      # you can dump details var if you need more info from buyer
      details = EXPRESS_GATEWAY.details_for(token)
      credits_total = JSON.pretty_generate(details.params["PaymentDetails"]["PaymentDetailsItem"])
      #puts get_bilbo_hash_quantity(JSON.parse(credits_total))
      self.total = get_bilbo_hash_quantity(JSON[credits_total]).to_i
      self.transaction_fee = payment_fee(self.total)
      self.first_name = details.params["first_name"]
      self.last_name = details.params["last_name"]
      self.express_payer_id = details.payer_id
    end
  end

  private

  def get_bilbo_hash_quantity(items_array)
    items_array.each do |elem|
     if I18n.transliterate(elem["Name"]).downcase.include? "credit"
       puts elem
      return elem["Quantity"]
      break
     end
    end
  end

  def express_purchase_options
   {
     :ip => ip.to_s,
     :token => express_token,
     :payer_id => express_payer_id,
     :currency => ENV.fetch("CURRENCY")
   }
  end

  def one_payment_at_a_time
    if self.paid_with == "SPEI" && Payment.where(user_id: self.user_id, status: 0).present?
      errors.add(:base, I18n.t('payments.errors.already_one_payment'))
    end
  end

  def notify_on_slack
    SlackNotifyWorker.perform_async("Revisar referencia de pago '#{self.spei_reference}' por la cantidad de #{self.total_in_cents}.")
  end
end
