class PaymentsController < ApplicationController
  access user: :all
  before_action :limit_credit, only: [:create,:express]
  def express
    order_total = (payment_params_express[:total].to_i  * 100)
    response = EXPRESS_GATEWAY.setup_purchase(order_total,
      ip: request.remote_ip,
      return_url: new_payment_url,
      cancel_return_url: root_url,
      currency: ENV.fetch("CURRENCY"),
      no_shipping: 1,
      allow_guest_checkout: false,
      items: [{name: "Bilbo Credits", description: "#{payment_params_express[:total]} Credits Purchase", quantity: payment_params_express[:total].to_i, amount: 100}]
    )
    redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
  end

  def new
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.paid_with = "Paypal Express"
    details = EXPRESS_GATEWAY.details_for(payment_params["express_token"])
    # uncomment if to allow only verified paypal accounts
    #if details.params["payer_status"] == "verified"
    if @payment.save
      if @payment.purchase #check model for this
        flash[:success] = "Haz comprado #{@payment.total} creditos"
      else
        flash[:error] = "No se pudo completar la transaccion"
      end
    else
      flash[:error] = "No se pudo completar la transaccion"
    end
    #else
    #  flash[:error] = "Debes utilizar una cuenta de paypal verificada"
    #end
    redirect_to root_path
  end

  def limit_credit
    previous_purchases = current_user.payments.where(created_at: Time.now.beginning_of_day..Time.now.end_of_day).sum(:total)
    credit_limit = current_user.credit_limit
    credit_purchase = payment_params_express[:total].to_i
     if credit_purchase + previous_purchases > credit_limit
       redirect_to root_path
       flash[:error] = t("payments.credit_limit")
     end
  end

  private

  def payment_params_express
    params.permit(:total)
  end

  def payment_params
    params.require(:payment).permit(:express_token).merge(:user_id => current_user.id, :ip => request.remote_ip)
  end
end
