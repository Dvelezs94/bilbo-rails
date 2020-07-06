class Payment < ApplicationRecord
  belongs_to :user
  has_one :invoice
  validates :express_token, uniqueness: true
  require 'json'
  def purchase
    response = EXPRESS_GATEWAY.purchase(total * 100, express_purchase_options)
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
      credits_total = JSON.pretty_generate(details.params["PaymentDetails"]["PaymentDetailsItem"])
      #puts get_bilbo_hash_quantity(JSON.parse(credits_total))
      self.total = get_bilbo_hash_quantity(JSON[credits_total]).to_i
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

end
