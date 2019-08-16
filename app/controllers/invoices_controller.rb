class PaymentsController < ApplicationController
  access user: :all

  def new
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.paid_with = "Paypal Express"
    if @payment.save
      if @payment.purchase #check model for this
        flash[:success] = "Haz comprado #{@payment.total} creditos"
      else
        flash[:error] = "No se pudo completar la transaccion"
      end
    else
      flash[:error] = "No se pudo completar la transaccion"
    end
    redirect_to root_path
  end

  private

  def get_invoices
    @invoices = current_user.invoices
  end

  def get_campaign
    @invoice = Invoice.includes(:payment).friendly.find(params[:id])
  end

  def verify_identity
    redirect_to invoices_path if @invoice.user != current_user
  end
end
