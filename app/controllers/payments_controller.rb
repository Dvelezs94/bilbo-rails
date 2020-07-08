class PaymentsController < ApplicationController
  access user: :all
  before_action :limit_credit, only: [:create,:express]
  include ApplicationHelper
  def express
    order_total = (payment_params_express[:total].to_i + payment_fee(payment_params_express[:total].to_i)) * 100
    response = EXPRESS_GATEWAY.setup_purchase(order_total,
      ip: request.remote_ip,
      return_url: new_payment_url,
      cancel_return_url: root_url,
      currency: ENV.fetch("CURRENCY"),
      no_shipping: 1,
      allow_guest_checkout: true,
      items: [
              {
                name: I18n.t("payments.bilbo_credits"),
                description: I18n.t("payments.credits_text"),
                quantity: payment_params_express[:total].to_i,
                amount: 100
              },
              {
                name: I18n.t("payments.transaction_fee"),
                description: I18n.t("payments.transaction_fee_text"),
                quantity: 1,
                amount: payment_fee(payment_params_express[:total].to_i) * 100
              }
             ]
    )
    redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
  end

  def new
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.paid_with = "Paypal Express"
    # uncomment if to allow only verified paypal accounts
    # details = EXPRESS_GATEWAY.details_for(payment_params["express_token"])
    # if details.params["payer_status"] == "verified"
    if @payment.save
      if @payment.purchase #check model for this
        SlackNotifyWorker.perform_async("El usuario #{current_user.email} ha comprado #{@payment.total} créditos")
        flash[:success] = I18n.t("payments.purchase_success", credits_number: @payment.total)
      else
        flash[:error] = I18n.t("payments.purchase_error")
      end
    else
      flash[:error] = I18n.t("payments.purchase_error")
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
