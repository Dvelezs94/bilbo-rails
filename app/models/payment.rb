class Payment < ApplicationRecord
  belongs_to :user
  has_one :invoice
  validates :express_token, uniqueness: true
  def purchase
    response = EXPRESS_GATEWAY.purchase(total.to_f, express_purchase_options)
    if response.success?
      if user.balance < 5
        user.increment!(:balance, by = total)
        user.resume_campaigns
      else
        user.increment!(:balance, by = total)
      end
    GenerateInvoiceWorker.perform_async(id)
    else
      # for debugging
      puts response.message
    end
    response.success?
  end


  def total_in_cents
    self.total.to_f
  end

  def express_token=(token)
    self[:express_token] = token
    if new_record? && !token.blank?
      # you can dump details var if you need more info from buyer
      details = EXPRESS_GATEWAY.details_for(token)
      self.total = details.params["order_total"].to_i
      self.first_name = details.params["first_name"]
      self.last_name = details.params["last_name"]
      self.express_payer_id = details.payer_id
    end
  end

  private

  def express_purchase_options
   {
     :ip => ip.to_s,
     :token => express_token,
     :payer_id => express_payer_id,
     :currency => ENV.fetch("CURRENCY")
   }
  end

end
