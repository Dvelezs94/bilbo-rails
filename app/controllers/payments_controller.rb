class PaymentsController < ApplicationController
  access user: :all
  # before_action :user_verified_for_purchase?, only: [:create, :express]
  before_action :verify_user_credit_limit, only: [:create, :express, :update_reference]
  before_action :get_payment, only: [:cancel_spei, :check_payment, :update_reference]
  before_action :identify_user, only: [:cancel_spei]
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

  # Generate the payment sheet for SPEI transfers
  def generate_sheet
    respond_to do |format|
        format.html
        format.pdf do
            render pdf: t("payments.payment_sheet"),
            page_size: 'A5',
            layout: "pdf.html",
            template: "payments/generate_sheet.html.haml",
            viewport_size: '1024x1280',
            orientation: "Portrait",
            lowquality: true,
            zoom: 1,
            dpi: 75
        end
    end
  end

  def create_spei
    @payment = Payment.new(spei_payment_params)
    @payment.paid_with = "SPEI"
    if @payment.save
      GenerateInvoiceWorker.perform_async(@payment.id)
      flash[:success] = I18n.t("payments.purchase_spei_success")
      @pdf_url = generate_sheet_payments_url(price: @payment.total_in_cents, format: :pdf)
    else
      flash[:error] = @payment.errors.full_messages.first
    end
  end

  # display modal for checking the payment
  def check_payment
  end

  # update the reference id to check the payment
  def update_reference
    if @payment.update(params.require(:payment).permit(:spei_reference))
      @payment.reviewing_payment!
      flash[:success] = I18n.t("payments.success.reference_sent")
    else
      flash[:error] = I18n.t("payments.errors.reference_failed")
    end
    redirect_to invoices_path
  end

  def cancel_spei
    if @payment.cancelled!
      flash[:success] = I18n.t("payments.status_update_success")
    else
      flash[:error] = I18n.t("payments.status_update_error")
    end
    redirect_to invoices_path
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.paid_with = "Paypal Express"
    # uncomment if to allow only verified paypal accounts
    # details = EXPRESS_GATEWAY.details_for(payment_params["express_token"])
    # if details.params["payer_status"] == "verified"
    if @payment.save
      @payment.reviewing_payment!
      if @payment.purchase #check model for this
        flash[:success] = I18n.t("payments.purchase_success", credits_number: @payment.total)
      else
        flash[:error] = I18n.t("payments.purchase_error")
      end
    else
      flash[:error] = I18n.t("payments.purchase_error")
    end
    redirect_to root_path
  end

  private

  def get_payment
    @payment = Payment.find(params[:id])
  end

  def identify_user
    if !(@payment.user == current_user)
      raise_not_found
    end
  end

  def verify_user_credit_limit
    #This method checks if the user has exceeded the credit limit for the current day
    previous_purchases = current_user.payments.where(created_at: Time.now.beginning_of_day..Time.now.end_of_day).sum(:total)
    credit_limit = current_user.credit_limit
    credit_purchase = payment_params_express[:total].to_i
     if credit_purchase + previous_purchases > credit_limit
       flash[:error] = t("payments.credit_limit")
       redirect_to root_path
     end
  end

  def user_verified_for_purchase?
    if !current_user.verified?
      flash[:error] = I18n.t("payments.purchase_error")
      redirect_to root_path
    end
  end

  def payment_params_express
    params.permit(:total)
  end

  def payment_params
    params.require(:payment).permit(:express_token).merge(:user_id => current_user.id, :ip => request.remote_ip)
  end

  def spei_payment_params
    params.require(:payment).permit(:total).merge(:user_id => current_user.id, :ip => request.remote_ip, :transaction_fee => 0)
  end
end
