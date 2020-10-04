class Admin::PaymentsController < ApplicationController
  access admin: :all
  before_action :get_payment, only: [:approve, :deny]

  def index
    @payments = Payment.where(paid_with: "SPEI").order(status: :asc)
  end

  def approve
    if @payment.paid!
      flash[:success] = "Pago aceptado, se entregaron los creditos al usuario"
    else
      flash[:error] = I18n.t("payments.status_update_error")
    end
    redirect_to admin_payments_path
  end

  def deny
    if @payment.rejected!
      flash[:success] = 'pago rechazado'
    else
      flash[:error] = I18n.t("payments.status_update_error")
    end
    redirect_to admin_payments_path
  end

  private
  def get_payment
    @payment = Payment.find(params[:id])
  end
end
